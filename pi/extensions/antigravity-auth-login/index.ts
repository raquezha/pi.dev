import { appendFileSync } from "node:fs";
import { createHash, randomBytes } from "node:crypto";
import { createServer, type IncomingMessage, type Server, type ServerResponse } from "node:http";
import { Readable } from "node:stream";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const DEFAULT_PROVIDER_ID = "antigravity-cli";
const LEGACY_PROVIDER_ID = "google-gemini-cli";
const PROVIDER_ID = process.env.ANTIGRAVITY_PROVIDER_ID?.trim() || DEFAULT_PROVIDER_ID;
const PROVIDER_NAME = process.env.ANTIGRAVITY_PROVIDER_NAME?.trim() || "Google Antigravity CLI";
const PROVIDER_API = "google-gemini-cli";
const AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth";
const TOKEN_URL = "https://oauth2.googleapis.com/token";
const REDIRECT_URI = "http://localhost:51121/oauth-callback";
const DEFAULT_CLIENT_ID = "1071006060591-tmhssin2h21lcre235vtolojh4g403ep.apps.googleusercontent.com";
const CODE_ASSIST_ENDPOINT = "https://daily-cloudcode-pa.sandbox.googleapis.com";
const ANTIGRAVITY_PROXY_PORT = 51122;
const ANTIGRAVITY_PROXY_BASE_URL = `http://127.0.0.1:${ANTIGRAVITY_PROXY_PORT}`;
const ANTIGRAVITY_LOG_FILE = `${process.env.HOME || "/tmp"}/.pi/agent/antigravity-proxy.log`;
const DEFAULT_PROJECT_ID = "rising-fact-p41fc";
const SCOPES = [
	"https://www.googleapis.com/auth/cloud-platform",
	"https://www.googleapis.com/auth/userinfo.email",
	"https://www.googleapis.com/auth/userinfo.profile",
	"https://www.googleapis.com/auth/cclog",
	"https://www.googleapis.com/auth/experimentsandconfigs",
];
const ANTIGRAVITY_SYSTEM_INSTRUCTION =
	"You are Antigravity, a powerful agentic AI coding assistant designed by the Google Deepmind team working on Advanced Agentic Coding." +
	"You are pair programming with a USER to solve their coding task. The task may require creating a new codebase, modifying or debugging an existing codebase, or simply answering a question." +
	"**Absolute paths only**" +
	"**Proactiveness**";
const ANTIGRAVITY_DEBUG = process.env.ANTIGRAVITY_DEBUG === "1" || process.env.ANTIGRAVITY_DEBUG === "true";

type ModelDef = {
	id: string;
	name: string;
	reasoning: boolean;
	input: Array<"text" | "image">;
	cost: { input: number; output: number; cacheRead: number; cacheWrite: number };
	contextWindow: number;
	maxTokens: number;
};

type ProxyHealth = {
	ok: boolean;
	provider: string;
	api: string;
	baseUrl: string;
};

function log(message: string): void {
	if (!ANTIGRAVITY_DEBUG) return;
	try {
		appendFileSync(ANTIGRAVITY_LOG_FILE, `[${new Date().toISOString()}] ${message}\n`);
	} catch {
		// ignore
	}
}

function getClientId(): string {
	return process.env.ANTIGRAVITY_CLIENT_ID?.trim() || DEFAULT_CLIENT_ID;
}

function getClientSecret(): string | undefined {
	return process.env.ANTIGRAVITY_CLIENT_SECRET?.trim() || undefined;
}

function generatePKCE(): { verifier: string; challenge: string } {
	const verifier = randomBytes(32).toString("base64url");
	const challenge = createHash("sha256").update(verifier).digest("base64url");
	return { verifier, challenge };
}

function startCallbackServer(): Promise<{ server: Server; getCode: () => Promise<{ code: string; state: string }> }> {
	return new Promise((resolve, reject) => {
		let resolveCode!: (value: { code: string; state: string }) => void;
		let rejectCode!: (error: Error) => void;

		const codePromise = new Promise<{ code: string; state: string }>((res, rej) => {
			resolveCode = res;
			rejectCode = rej;
		});

		const server = createServer((req, res) => {
			const url = new URL(req.url || "", "http://localhost:51121");
			if (url.pathname !== "/oauth-callback") {
				res.writeHead(404);
				res.end();
				return;
			}

			const code = url.searchParams.get("code");
			const state = url.searchParams.get("state");
			const error = url.searchParams.get("error");

			if (error) {
				res.writeHead(400, { "Content-Type": "text/html" });
				res.end(`<html><body><h1>Authentication Failed</h1><p>Error: ${error}</p></body></html>`);
				rejectCode(new Error(`OAuth error: ${error}`));
				return;
			}

			if (!code || !state) {
				res.writeHead(400, { "Content-Type": "text/html" });
				res.end(`<html><body><h1>Authentication Failed</h1><p>Missing code or state.</p></body></html>`);
				rejectCode(new Error("Missing code or state in OAuth callback"));
				return;
			}

			res.writeHead(200, { "Content-Type": "text/html" });
			res.end(`<html><body><h1>Authentication Successful</h1><p>You can close this window and return to pi.</p></body></html>`);
			resolveCode({ code, state });
		});

		server.on("error", reject);
		server.listen(51121, "127.0.0.1", () => resolve({ server, getCode: () => codePromise }));
	});
}

function antigravityModels(): ModelDef[] {
	return [
		{ id: "gemini-3.1-pro-high", name: "Gemini 3.1 Pro (high) (Google Antigravity)", reasoning: true, input: ["text", "image"], cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }, contextWindow: 1048576, maxTokens: 65535 },
		{ id: "gemini-3.1-pro-low", name: "Gemini 3.1 Pro (low) (Google Antigravity)", reasoning: true, input: ["text", "image"], cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }, contextWindow: 1048576, maxTokens: 65535 },
		{ id: "gemini-3-flash", name: "Gemini 3 Flash (Google Antigravity)", reasoning: true, input: ["text", "image"], cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }, contextWindow: 1048576, maxTokens: 65535 },
		{ id: "claude-sonnet-4-6", name: "Claude Sonnet 4.6 (Google Antigravity)", reasoning: true, input: ["text", "image"], cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }, contextWindow: 200000, maxTokens: 64000 },
		{ id: "claude-opus-4-6-thinking", name: "Claude Opus 4.6 Thinking (Google Antigravity)", reasoning: true, input: ["text", "image"], cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }, contextWindow: 200000, maxTokens: 64000 },
		{ id: "gpt-oss-120b", name: "GPT-OSS-120b (Google Antigravity)", reasoning: false, input: ["text"], cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }, contextWindow: 131072, maxTokens: 32768 },
	];
}

function parseModelsFromDocs(html: string): ModelDef[] {
	const section = html.split(/##\s+Reasoning Model/i)[1] ?? "";
	const out = antigravityModels();
	if (!section) return out;
	const normalized = section.toLowerCase();
	const filtered = out.filter((m) => normalized.includes(m.id.toLowerCase()) || normalized.includes(m.name.toLowerCase().split(" (")[0]!.toLowerCase()));
	return filtered.length > 0 ? filtered : out;
}

function summarizeModelIds(models: ModelDef[]): string {
	return models.map((model) => model.id).join(",");
}

function sanitizePath(pathname: string, search: string): string {
	return `${pathname}${search}`;
}

function inferModelId(payload: any): string | undefined {
	return payload?.model ?? payload?.modelId ?? payload?.request?.model ?? payload?.request?.modelId ?? payload?.request?.config?.model;
}

function summarizePayload(payload: any): string {
	if (!payload || typeof payload !== "object") return "payload=none";

	const fields = [
		`requestType=${String(payload.requestType ?? "unknown")}`,
		`model=${inferModelId(payload) ?? "unknown"}`,
		`requestId=${String(payload.requestId ?? payload?.request?.requestId ?? "missing")}`,
		`hasRequest=${Boolean(payload.request)}`,
		`hasSystemInstruction=${Boolean(payload?.request?.systemInstruction)}`,
	];

	return fields.join(" ");
}

async function loadAntigravityModels(): Promise<ModelDef[]> {
	try {
		const res = await fetch("https://antigravity.google/docs/models");
		if (!res.ok) return antigravityModels();
		return parseModelsFromDocs(await res.text());
	} catch {
		return antigravityModels();
	}
}

async function loginAntigravity(callbacks: any): Promise<any> {
	const { verifier, challenge } = generatePKCE();
	const { server, getCode } = await startCallbackServer();
	const clientSecret = getClientSecret();
	log(`oauth login start provider=${PROVIDER_ID} redirect=${REDIRECT_URI}`);

	try {
		const authParams = new URLSearchParams({
			client_id: getClientId(),
			response_type: "code",
			redirect_uri: REDIRECT_URI,
			scope: SCOPES.join(" "),
			code_challenge: challenge,
			code_challenge_method: "S256",
			state: verifier,
			access_type: "offline",
			prompt: "consent",
		});

		callbacks.onAuth?.({ url: `${AUTH_URL}?${authParams.toString()}`, instructions: "Complete the browser sign-in. pi will capture the callback automatically." });
		callbacks.onProgress?.("Waiting for browser OAuth callback...");

		const { code, state } = await getCode();
		if (state !== verifier) throw new Error("OAuth state mismatch");
		log(`oauth callback received provider=${PROVIDER_ID} state=ok codeLength=${code.length}`);

		const tokenResponse = await fetch(TOKEN_URL, {
			method: "POST",
			headers: { "Content-Type": "application/x-www-form-urlencoded" },
			body: new URLSearchParams({
				client_id: getClientId(),
				...(clientSecret ? { client_secret: clientSecret } : {}),
				code,
				grant_type: "authorization_code",
				redirect_uri: REDIRECT_URI,
				code_verifier: verifier,
			}),
		});

		if (!tokenResponse.ok) throw new Error(`Token exchange failed: ${await tokenResponse.text()}`);
		const tokenData = (await tokenResponse.json()) as { access_token: string; refresh_token: string; expires_in: number };
		if (!tokenData.refresh_token) throw new Error("No refresh token received from Google.");
		log(`oauth login success provider=${PROVIDER_ID} projectId=${DEFAULT_PROJECT_ID} expiresIn=${tokenData.expires_in}`);

		return { type: "oauth", refresh: tokenData.refresh_token, access: tokenData.access_token, expires: Date.now() + tokenData.expires_in * 1000 - 5 * 60 * 1000, projectId: DEFAULT_PROJECT_ID };
	} finally {
		server.close();
	}
}

async function refreshAntigravityToken(credentials: any): Promise<any> {
	const clientSecret = getClientSecret();
	log(`oauth refresh start provider=${PROVIDER_ID} projectId=${credentials.projectId || DEFAULT_PROJECT_ID}`);
	const response = await fetch(TOKEN_URL, {
		method: "POST",
		headers: { "Content-Type": "application/x-www-form-urlencoded" },
		body: new URLSearchParams({
			client_id: getClientId(),
			...(clientSecret ? { client_secret: clientSecret } : {}),
			refresh_token: credentials.refresh,
			grant_type: "refresh_token",
		}),
	});

	if (!response.ok) throw new Error(`Antigravity token refresh failed: ${await response.text()}`);
	const data = (await response.json()) as { access_token: string; expires_in: number; refresh_token?: string };
	log(`oauth refresh success provider=${PROVIDER_ID} expiresIn=${data.expires_in}`);
	return { type: "oauth", refresh: data.refresh_token || credentials.refresh, access: data.access_token, expires: Date.now() + data.expires_in * 1000 - 5 * 60 * 1000, projectId: credentials.projectId || DEFAULT_PROJECT_ID };
}

function readJsonBody(req: IncomingMessage): Promise<string> {
	return new Promise((resolve, reject) => {
		const chunks: Buffer[] = [];
		req.on("data", (c) => chunks.push(Buffer.isBuffer(c) ? c : Buffer.from(c)));
		req.on("end", () => resolve(Buffer.concat(chunks).toString("utf8")));
		req.on("error", reject);
	});
}

function proxyResponse(upstream: Response, res: ServerResponse) {
	log(`upstream status=${upstream.status} contentType=${upstream.headers.get("content-type") || "unknown"}`);
	res.writeHead(upstream.status, Object.fromEntries(upstream.headers.entries()));
	if (!upstream.body) {
		res.end();
		return;
	}
	const nodeStream = Readable.fromWeb(upstream.body as any);
	nodeStream.on("error", () => res.destroy());
	nodeStream.pipe(res);
}

async function proxyHealth(): Promise<{ ok: boolean; status?: number; body?: ProxyHealth; error?: string }> {
	try {
		const response = await fetch(`${ANTIGRAVITY_PROXY_BASE_URL}/health`);
		if (!response.ok) return { ok: false, status: response.status, error: `HTTP ${response.status}` };
		return { ok: true, status: response.status, body: (await response.json()) as ProxyHealth };
	} catch (error) {
		return { ok: false, error: error instanceof Error ? error.message : String(error) };
	}
}

async function startAntigravityProxy(): Promise<Server> {
	const server = createServer(async (req, res) => {
		try {
			const url = new URL(req.url || "/", CODE_ASSIST_ENDPOINT);
			if (url.pathname === "/health") {
				res.writeHead(200, { "Content-Type": "application/json" });
				const health: ProxyHealth = { ok: true, provider: PROVIDER_ID, api: PROVIDER_API, baseUrl: ANTIGRAVITY_PROXY_BASE_URL };
				res.end(JSON.stringify(health));
				return;
			}
			const bodyText = ["GET", "HEAD"].includes(req.method || "GET") ? "" : await readJsonBody(req);
			let payload: any = undefined;
			if (bodyText) {
				try {
					payload = JSON.parse(bodyText);
				} catch {
					log(`proxy request parse=invalid-json method=${req.method || "GET"} path=${sanitizePath(url.pathname, url.search)} bodyLength=${bodyText.length}`);
					payload = undefined;
				}
			}
			if (payload?.request) {
				payload.requestType = "agent";
				payload.userAgent = "antigravity";
				payload.requestId ||= `agent-${Date.now()}-${Math.random().toString(36).slice(2, 11)}`;
				const existing = payload.request.systemInstruction?.parts ?? [];
				payload.request.systemInstruction = { role: "user", parts: [{ text: ANTIGRAVITY_SYSTEM_INSTRUCTION }, ...existing] };
			}
			const outgoingBody = bodyText ? (payload ? JSON.stringify(payload) : bodyText) : undefined;
			const headers: Record<string, string> = {
				"Content-Type": req.headers["content-type"]?.toString() || "application/json",
				Accept: req.headers.accept?.toString() || "text/event-stream",
				Authorization: req.headers.authorization?.toString() || "",
				"User-Agent": "antigravity/1.21.9 darwin/arm64",
			};
			log(`proxy request method=${req.method || "GET"} path=${sanitizePath(url.pathname, url.search)} contentType=${headers["Content-Type"]} accept=${headers.Accept} hasAuth=${headers.Authorization.length > 0} ${summarizePayload(payload)}`);
			const upstream = await fetch(`${CODE_ASSIST_ENDPOINT}${url.pathname}${url.search}`, { method: req.method, headers, body: outgoingBody });
			proxyResponse(upstream, res);
		} catch (error) {
			log(`proxy error=${error instanceof Error ? error.message : String(error)}`);
			res.writeHead(500, { "Content-Type": "application/json" });
			res.end(JSON.stringify({ error: error instanceof Error ? error.message : String(error) }));
		}
	});
	await new Promise<void>((resolve, reject) => server.listen(ANTIGRAVITY_PROXY_PORT, "127.0.0.1", (err?: Error) => (err ? reject(err) : resolve())));
	log(`proxy started port=${ANTIGRAVITY_PROXY_PORT} provider=${PROVIDER_ID} api=${PROVIDER_API} baseUrl=${ANTIGRAVITY_PROXY_BASE_URL}`);
	return server;
}

export default async function (pi: ExtensionAPI) {
	const models = await loadAntigravityModels();
	log(`extension activate provider=${PROVIDER_ID} api=${PROVIDER_API} legacyProvider=${LEGACY_PROVIDER_ID} models=${summarizeModelIds(models)}`);
	const proxy = await startAntigravityProxy();

	const register = () => {
		log(`provider register provider=${PROVIDER_ID} api=${PROVIDER_API} legacyProvider=${LEGACY_PROVIDER_ID} baseUrl=${ANTIGRAVITY_PROXY_BASE_URL} modelCount=${models.length}`);
		pi.registerProvider(PROVIDER_ID, {
			name: PROVIDER_NAME,
			baseUrl: ANTIGRAVITY_PROXY_BASE_URL,
			api: PROVIDER_API,
			models,
			oauth: {
				name: PROVIDER_NAME,
				login: loginAntigravity,
				refreshToken: refreshAntigravityToken,
				getApiKey: (credentials: any) => JSON.stringify({ token: credentials.access, projectId: credentials.projectId || DEFAULT_PROJECT_ID }),
			},
		} as any);
	};

	register();

	pi.registerCommand("antigravity.doctor", {
		description: "Show Antigravity provider/proxy diagnostics",
		handler: async (_args, ctx) => {
			const health = await proxyHealth();
			const lines = [
				`provider=${PROVIDER_ID}`,
				`legacyProvider=${LEGACY_PROVIDER_ID}`,
				`api=${PROVIDER_API}`,
				`baseUrl=${ANTIGRAVITY_PROXY_BASE_URL}`,
				`debug=${ANTIGRAVITY_DEBUG ? "on" : "off"}`,
				`logFile=${ANTIGRAVITY_LOG_FILE}`,
				`proxyHealth=${health.ok ? "ok" : "failed"}`,
			];

			if (health.body) {
				lines.push(`proxyProvider=${health.body.provider}`);
				lines.push(`proxyApi=${health.body.api}`);
			}
			if (!health.ok && health.error) lines.push(`error=${health.error}`);

			const summary = lines.join("\n");
			log(`doctor run provider=${PROVIDER_ID} proxyHealth=${health.ok ? "ok" : "failed"}`);
			if (ctx.hasUI) {
				ctx.ui.notify(`Antigravity doctor\n${summary}`, health.ok ? "info" : "warning");
			}
			console.log(summary);
		},
	});

	return {
		deactivate: async () => {
			log(`extension deactivate provider=${PROVIDER_ID}`);
			try {
				pi.unregisterProvider(PROVIDER_ID);
				log(`provider unregister provider=${PROVIDER_ID}`);
			} catch {}
			try {
				proxy.close();
				log(`proxy stopped port=${ANTIGRAVITY_PROXY_PORT}`);
			} catch {}
		},
	};
}
