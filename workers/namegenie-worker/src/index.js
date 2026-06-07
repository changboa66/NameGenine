const GENERATION_PROMPT = `You are a Chinese naming expert. Generate 5 Chinese given names based on the preferences below.

Preferences:
- Gender: {{gender}}
- Phonetic input: {{phoneticInput}}
- Desired meaning: {{meanings}}
- Character count: {{characterCount}}
- Surname (for compatibility check): {{surname}}

Rules:
1. Each name MUST be {{characterCount}} characters (not counting surname)
2. Names should sound pleasant in Mandarin Chinese
3. AVOID: 3rd-tone + 3rd-tone combinations (e.g., 李有 - too awkward to pronounce)
4. AVOID: names that are very common in the 2010s (e.g., 子轩, 梓涵, 浩宇)
5. AVOID: characters with negative or embarrassing homophones
6. AVOID: characters that look like they belong to an older generation
7. If phonetic input is provided, try to approximate the sound with Chinese syllables
8. If meanings are provided, prioritize characters that carry those meanings
9. If a surname is provided, ensure the full name sounds natural together
10. Each name should have a coherent overall meaning

Return valid JSON ONLY, no markdown, no explanation:
{
  "candidates": [
    {
      "hanzi": "example",
      "pinyin": "Lì Huá",
      "meaning": "example meaning in English",
      "relevance": 0.95
    }
  ]
}`;

const RANDOM_PROMPT = `You are a Chinese naming expert. Generate 5 Chinese given names in random/surprise mode.

Preferences (may be empty — fill in your own creativity if so):
- Gender: {{gender}}
- Character count: {{characterCount}}
- Surname (for compatibility check): {{surname}}

Rules:
1. Return 5 names across 3 DISTINCT STYLES:
   - Two names: CLASSIC / TRADITIONAL — timeless, elegant, established characters
   - Two names: MODERN / POPULAR — contemporary feel, trendy characters
   - One name: UNIQUE / LITERARY — rare characters, poetic or artistic flair
2. Names should sound pleasant in Mandarin Chinese
3. AVOID: 3rd-tone + 3rd-tone combinations
4. AVOID: names that are very common in the 2010s (e.g., 子轩, 梓涵, 浩宇)
5. AVOID: characters with negative or embarrassing homophones
6. If gender is provided, respect it; otherwise choose freely
7. If character count is provided, respect it; otherwise mix 2-character names
8. If a surname is provided, ensure the full name sounds natural together
9. Label each candidate with its style in the meaning field, e.g. "Classic — bright radiance"

Return valid JSON ONLY, no markdown, no explanation:
{
  "candidates": [
    {
      "hanzi": "example",
      "pinyin": "Lì Huá",
      "meaning": "Classic — example meaning",
      "relevance": 0.9
    }
  ]
}`;

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

export default {
  async fetch(request, env) {
    if (request.method !== 'POST') {
      return errorResponse(405, 'Method not allowed. Use POST.');
    }

    const contentType = request.headers.get('Content-Type') || '';
    if (!contentType.includes('application/json')) {
      return errorResponse(400, 'Content-Type must be application/json');
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return errorResponse(400, 'Invalid JSON body');
    }

    const ip = getClientIP(request);
    const deviceId = request.headers.get('X-Device-ID') || '';
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

    const { action, random, ...params } = body;

    let prompt;
    if (action === 'generate') {
      if (random) {
        prompt = buildPrompt(RANDOM_PROMPT, {
          gender: params.gender || '',
          characterCount: params.characterCount || '',
          surname: params.surname || '',
        });
      } else {
        prompt = buildPrompt(GENERATION_PROMPT, {
          gender: params.gender || 'neutral',
          phoneticInput: params.phoneticInput || '',
          meanings: params.meanings ? params.meanings.join(', ') : '',
          characterCount: params.characterCount || '2',
          surname: params.surname || '',
        });
      }
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

      return new Response(JSON.stringify(parsed), {
        headers: { 'Content-Type': 'application/json', ...rateLimitHeaders() },
      });
    } catch (err) {
      clearTimeout(timeoutId);
      if (err.name === 'AbortError') {
        return errorResponse(504, 'AI API request timed out', rateLimitHeaders());
      }
      return errorResponse(502, 'AI API request failed', rateLimitHeaders());
    }
  },
};
