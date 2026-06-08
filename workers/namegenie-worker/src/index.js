function buildGeneratePrompt(vars) {
  const charCount = vars.characterCount || '2';
  const exampleHanzi = charCount === '3' ? 'example threechars' : 'example name';
  const examplePinyin = charCount === '3' ? 'Example Three Pinyin' : 'Example Pinyin';

  return `You are a Chinese naming expert. Generate 5 Chinese given names (名). Each time you MUST produce DIFFERENT names — be creative and avoid repeating names from previous generations.

Preferences:
- Gender: ${vars.gender}
- Phonetic input: ${vars.phoneticInput}
- Desired meanings: ${vars.meanings}
- Character count: ${charCount}

Rules:
1. Return 5 names across 3 DISTINCT STYLES:
   - Two names: CLASSIC / TRADITIONAL — timeless, elegant, established characters
   - Two names: MODERN / POPULAR — contemporary feel, trendy characters
   - One name: UNIQUE / LITERARY — rare characters, poetic or artistic flair
2. STRONGLY VARY your results each time. Do NOT reuse names from previous outputs.
3. Names should sound pleasant in Mandarin Chinese
4. AVOID: 3rd-tone + 3rd-tone combinations
5. AVOID: names that are very common in the 2010s
6. AVOID: characters with negative or embarrassing homophones
7. When phonetic input is provided, you MUST choose characters whose pinyin approximates the sound. This is top priority.
8. If meanings are provided, prioritize characters that carry those meanings
9. Label each candidate with its style in the meaning field, e.g. "Classic — English meaning"
10. If gender is provided, respect it; otherwise choose freely
11. IMPORTANT: pinyin MUST have each character's pinyin separated by a space. For a 3-character name like "李小明", pinyin MUST be "Li Xiao Ming" — NOT "Li Xiaoming". Each character gets its own pinyin word.

CRITICAL: Each hanzi value MUST contain EXACTLY ${charCount} characters. Not ${charCount === '3' ? '2, not 1' : '3, not 1'} — exactly ${charCount}. Count every character carefully before outputting.

CRITICAL: pinyin MUST have exactly ${charCount} space-separated words — one word per hanzi character. For example, a 3-character name's pinyin must be "Li Jian Ping" (3 words), NOT "Li Jianping" (2 words). You MUST capitalize only the first letter of each syllable.

Return valid JSON ONLY, no markdown, no explanation:
{
  "candidates": [
    {
      "hanzi": "${exampleHanzi}",
      "pinyin": "${examplePinyin}",
      "meaning": "Classic — English meaning",
      "relevance": 0.9
    }
  ]
}

CRITICAL: hanzi must contain only the given name — never include the surname.`;
}

const DETAIL_PROMPT = `You are a Chinese naming expert. Provide a detailed breakdown of the Chinese name below.

Name: {{hanzi}}
Pinyin: {{pinyin}}

For each character in the name, provide:
1. Character meaning and etymology
2. Radical and stroke count
3. How this character is commonly used in names

For the full name, provide:
4. The cultural background, any idioms or literary references
5. Notable people with the same name or characters
6. A pronunciation guide for non-native speakers (how to approximate the sounds)

Return valid JSON ONLY, no markdown, no explanation:
{
  "detail": {
    "hanzi": "example",
    "pinyin": "Lì Huá",
    "characterBreakdown": [
      {
        "character": "丽",
        "meaning": "beautiful, lovely. Originally meant 'to pair' or 'to attach', later borrowed for its phonetic value to mean beauty.",
        "radical": "丶 (dot) or 一 (one)",
        "strokeCount": 7,
        "nameUsage": "Very common in female names, conveys elegance and grace"
      }
    ],
    "pronunciation": {
      "withTones": "Lì Huá",
      "guideForLearners": "Lee Hwah - 'Lee' rhymes with 'see', 'Hwah' rhymes with 'squash'"
    },
    "culturalBackground": "The name 丽华 has been popular across generations...",
    "namesakes": ["Notable person 1", "Notable person 2"]
  }
}`;

function buildPrompt(template, variables) {
  let result = template;
  for (const [key, value] of Object.entries(variables)) {
    result = result.replace(new RegExp(`{{${key}}}`, 'g'), value || '');
  }
  return result;
}

function errorResponse(status, message, extraHeaders = {}) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { 'Content-Type': 'application/json', ...extraHeaders },
  });
}

function getClientIP(request) {
  return request.headers.get('CF-Connecting-IP')
    || request.headers.get('X-Forwarded-For')?.split(',')[0]?.trim()
    || 'unknown';
}

async function sha256(text) {
  const hash = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text));
  return Array.from(new Uint8Array(hash)).map(b => b.toString(16).padStart(2, '0')).join('');
}

async function computeHMAC(secret, message) {
  const key = await crypto.subtle.importKey(
    'raw', new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false, ['sign']
  );
  const sig = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(message));
  return Array.from(new Uint8Array(sig)).map(b => b.toString(16).padStart(2, '0')).join('');
}

async function verifySignature(headers, rawBody, secrets) {
  const signature = headers.get('X-Signature');
  const timestamp = headers.get('X-Timestamp');

  if (!signature || !timestamp) return false;

  const now = Math.floor(Date.now() / 1000);
  const ts = parseInt(timestamp, 10);
  if (isNaN(ts) || Math.abs(now - ts) > 30) return false;

  const contentType = headers.get('Content-Type') || 'application/json';
  const bodyHash = await sha256(rawBody);
  const message = `POST\n${contentType}\n${bodyHash}`;

  for (const secret of secrets) {
    const expected = await computeHMAC(secret, message);
    if (expected === signature) return true;
  }

  return false;
}

async function checkRateLimit(kv, type, identifier, limit, windowSec) {
  if (!identifier || identifier === 'unknown') return { allowed: true, remaining: limit };

  const key = `rl:${type}:${identifier}`;
  const now = Math.floor(Date.now() / 1000);
  const cutoff = now - windowSec;

  let timestamps = [];
  const existing = await kv.get(key, { type: 'text' });
  if (existing) {
    try { timestamps = JSON.parse(existing); } catch { timestamps = []; }
  }

  timestamps = timestamps.filter(ts => ts > cutoff);

  if (timestamps.length >= limit) {
    const oldestInWindow = timestamps[0];
    const resetIn = Math.max(1, oldestInWindow + windowSec - now);
    return {
      allowed: false,
      remaining: 0,
      reset: now + resetIn,
    };
  }

  timestamps.push(now);
  await kv.put(key, JSON.stringify(timestamps), { expirationTtl: windowSec * 2 + 60 });
  return { allowed: true, remaining: limit - timestamps.length, reset: now + windowSec };
}

async function recordDevice(db, deviceId) {
  if (!db || !deviceId) return;
  try {
    const now = Math.floor(Date.now() / 1000);
    await db.prepare(
      `INSERT INTO devices (id, first_seen, last_seen, req_count) VALUES (?, ?, ?, 1)
       ON CONFLICT(id) DO UPDATE SET last_seen = excluded.last_seen, req_count = req_count + 1`
    ).bind(deviceId, now, now).run();
  } catch {}
}

export default {
  async fetch(request, env, ctx) {
    if (request.method !== 'POST') {
      return errorResponse(405, 'Method not allowed. Use POST.');
    }

    const contentType = request.headers.get('Content-Type') || '';
    if (!contentType.includes('application/json')) {
      return errorResponse(400, 'Content-Type must be application/json');
    }

    let rawBody;
    try {
      rawBody = await request.text();
    } catch {
      return errorResponse(400, 'Failed to read request body');
    }

    let body;
    try {
      body = JSON.parse(rawBody);
    } catch {
      return errorResponse(400, 'Invalid JSON body');
    }

    const signingSecrets = [env.SIGNING_KEY];
    if (env.SIGNING_KEY_OLD) signingSecrets.push(env.SIGNING_KEY_OLD);

    const valid = await verifySignature(request.headers, rawBody, signingSecrets);
    if (!valid) {
      return errorResponse(401, 'Unauthorized: invalid or missing request signature');
    }

    const deviceId = request.headers.get('X-Device-ID') || '';

    // Blacklist check
    if (deviceId && env.namegenie_devices) {
      try {
        const device = await env.namegenie_devices.prepare(
          'SELECT blacklisted FROM devices WHERE id = ?'
        ).bind(deviceId).first();
        if (device && device.blacklisted === 1) {
          return errorResponse(403, 'Device is blacklisted');
        }
      } catch {}
    }

    const ip = getClientIP(request);
    const kv = env.RATE_LIMIT_KV;

    const ipCheck = await checkRateLimit(kv, 'ip', ip, 100, 60);
    if (!ipCheck.allowed) {
      return errorResponse(429, 'Rate limit exceeded. Please try again later.', {
        'X-RateLimit-Remaining': '0',
        'X-RateLimit-Reset': String(ipCheck.reset),
      });
    }

    let deviceCheck = null;
    if (deviceId) {
      deviceCheck = await checkRateLimit(kv, 'device', deviceId, 50, 60);
      if (!deviceCheck.allowed) {
        return errorResponse(429, 'Rate limit exceeded. Please try again later.', {
          'X-RateLimit-Remaining': '0',
          'X-RateLimit-Reset': String(deviceCheck.reset),
        });
      }
    }

    function rateLimitHeaders() {
      const remaining = deviceCheck
        ? Math.min(ipCheck.remaining, deviceCheck.remaining)
        : ipCheck.remaining;
      const reset = deviceCheck
        ? Math.max(ipCheck.reset, deviceCheck.reset)
        : ipCheck.reset;
      return {
        'X-RateLimit-Remaining': String(remaining),
        'X-RateLimit-Reset': String(reset),
      };
    }

    const { action, ...params } = body;

    let prompt;
    if (action === 'generate') {
      prompt = buildGeneratePrompt({
        gender: params.gender || '',
        phoneticInput: params.phoneticInput || '',
        meanings: params.meanings ? params.meanings.join(', ') : '',
        characterCount: params.characterCount || '2',
      });
    } else if (action === 'detail') {
      prompt = buildPrompt(DETAIL_PROMPT, {
        hanzi: params.hanzi || '',
        pinyin: params.pinyin || '',
      });
    } else {
      return errorResponse(400, 'Invalid action. Use "generate" or "detail".');
    }

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000);

    try {
      const apiKey = env.DEEPSEEK_API_KEY;
      if (!apiKey) {
        return errorResponse(500, 'Server configuration error', rateLimitHeaders());
      }

      const response = await fetch('https://api.deepseek.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: 'deepseek-chat',
          messages: [
            { role: 'system', content: 'You are a helpful assistant that outputs valid JSON only.' },
            { role: 'user', content: prompt },
          ],
          temperature: 0.8,
          max_tokens: 1500,
        }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        const errorText = await response.text();
        return errorResponse(502, `AI API error: ${response.status}`, rateLimitHeaders());
      }

      const data = await response.json();
      const content = data.choices?.[0]?.message?.content;

      if (!content) {
        return errorResponse(502, 'Empty response from AI API', rateLimitHeaders());
      }

      let parsed;
      try {
        parsed = JSON.parse(content);
      } catch {
        return errorResponse(502, 'Invalid JSON from AI API', rateLimitHeaders());
      }

      // Fix pinyin spacing for generate results
      if (action === 'generate' && parsed.candidates) {
        for (const c of parsed.candidates) {
          if (c.hanzi && c.pinyin) {
            const expected = c.hanzi.length;
            const parts = c.pinyin.split(/\s+/).filter(Boolean);
            if (parts.length !== expected) {
              // Try splitting merged parts on uppercase letters
              const expanded = [];
              for (const part of parts) {
                let current = '';
                for (let i = 0; i < part.length; i++) {
                  const ch = part[i];
                  if (i > 0 && ch >= 'A' && ch <= 'Z' && current) {
                    expanded.push(current);
                    current = ch;
                  } else {
                    current += ch;
                  }
                }
                if (current) expanded.push(current);
              }
              if (expanded.length === expected) {
                c.pinyin = expanded.join(' ');
              }
            }
          }
        }
      }

      const result = new Response(JSON.stringify(parsed), {
        headers: { 'Content-Type': 'application/json', ...rateLimitHeaders() },
      });
      ctx.waitUntil(recordDevice(env.namegenie_devices, deviceId));
      return result;
    } catch (err) {
      clearTimeout(timeoutId);
      if (err.name === 'AbortError') {
        return errorResponse(504, 'AI API request timed out', rateLimitHeaders());
      }
      return errorResponse(502, 'AI API request failed', rateLimitHeaders());
    }
  },
};
