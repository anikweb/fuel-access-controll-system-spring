# FACS — Fuel Access Control System

Spring Boot 4 + JSP app for vehicle fuel-access registration. Users sign up with personal info, vehicle details, and a security step; OTP via bulksmsbd confirms the mobile number; signed-in users land on a dashboard.

---

## Prerequisites

| Tool | Why |
|------|------|
| **JDK 17+** | Build + run the app. |
| **MySQL 8+** | Persistence. Listens on `localhost:3306`. DB `facs-spring` is auto-created on first launch. |
| **Node.js + npm** | Only needed to rebuild Tailwind CSS when JSP/tag files change. The compiled CSS at `src/main/resources/static/css/app.css` ships in git so the app runs without Node. |
| **Maven Wrapper** | Already in repo (`./mvnw`). Don't need a system Maven install. |

---

## Configuration

Everything lives in `src/main/resources/application.properties`. Sensitive values read from environment variables; the values in the file are dev fallbacks.

### Environment variables (set these in production)

| Variable | Used for |
|----------|----------|
| `DB_USER` | MySQL username (fallback: `root`) |
| `DB_PASSWORD` | MySQL password (fallback: `12345678`) |
| `FACS_SMS_API_KEY` | bulksmsbd API key — **rotate the committed default before any real use** |
| `FACS_SMS_SENDER_ID` | bulksmsbd approved sender ID |

### Tunable properties

| Property | Default | Effect |
|----------|---------|--------|
| `server.port` | `8081` | HTTP port. |
| `facs.sms.provider` | `bulksmsbd` | Set to `console` in local dev to log OTPs instead of sending real SMS. |
| `facs.otp.length` | `6` | OTP digit count. |
| `facs.otp.expiry-seconds` | `300` | OTP validity window. |
| `facs.otp.max-attempts` | `5` | Per-challenge wrong-guess cap. |
| `facs.uploads.dir` | `./uploads` | Local folder for user uploads. |
| `facs.uploads.url-prefix` | `/uploads` | Public URL prefix for served uploads. |

---

## Running

### First time

```bash
./mvnw install          # download Java deps
npm install             # download Tailwind (only if you'll edit CSS)
```

### Dev loop

```bash
# Terminal 1 — rebuild CSS on JSP changes (only needed if editing styles/JSPs)
npm run dev

# Terminal 2 — run the app with hot class reload
./mvnw spring-boot:run
```

Open <http://localhost:8081>. MySQL must be running before startup. Hibernate (`spring.jpa.hibernate.ddl-auto=update`) creates/updates tables automatically — no migrations to run.

### Production build

```bash
npm run build           # minified CSS
./mvnw clean package    # produces target/facs-0.0.1-SNAPSHOT.war
```

Deploy the WAR to an external Tomcat 10+ (Jakarta EE 10), or run with the embedded server via `java -jar` after switching packaging.

---

## Architecture cheat sheet

- **MVC**: JSP views + custom tag library under `src/main/webapp/WEB-INF/tags/`. Controllers in `controller/`, business logic in `service/`, JPA entities in `model/`, repositories in `repository/`.
- **Spring Security**: session-based form login on `/signin`. Anonymous users see the landing page; everything else requires auth. CSRF is enabled.
- **DI**: constructor injection via Lombok `@RequiredArgsConstructor` everywhere.
- **Config classes**: all `@ConfigurationProperties` beans (Sms/Otp/Storage) auto-registered by `@ConfigurationPropertiesScan` on `FacsApplication`.

---

## Feature → key files

| Feature | Where it lives |
|---------|----------------|
| Landing / signin / signin redirects | `controller/HomeController`, `config/SecurityConfig`, `service/AppUserDetailsService`, `webapp/.../user/signin.jsp` |
| Signup wizard (Personal → Vehicle → Security → Review → OTP) | `controller/SignupController` + `service/RegistrationService`, `webapp/.../signup/*.jsp` |
| OTP issue + verify (signup AND password reset) | `service/OtpService`, `model/OtpChallenge`, `webapp/.../otp/verify-otp.jsp`, `webapp/.../static/js/otp.js` |
| SMS delivery | `service/SmsSender` (interface), `BulkSmsBdSender` (real) / `ConsoleSmsSender` (dev), wired in `config/SmsConfig` |
| Password reset | `controller/PasswordResetController` + `service/UserService` |
| File uploads (photos, license, plate) | `service/FileStorageService` (validates magic bytes, stores under `facs.uploads.dir`), `config/StorageProperties`, `webapp/.../tags/uploadZone.tag` + `avatarUpload.tag` |
| Dashboard | `controller/DashboardController` + `service/UserService.prepareDashboard()`, `webapp/.../user/dashboard.jsp` |

## Shared utilities (single source of truth)

| Util | Used by |
|------|---------|
| `util/PasswordRules` | Signup form validation (annotation constants) + password-reset check |
| `util/MobileNumbers` | Normalizes 11/13-digit Bangladesh numbers to `880XXXXXXXXXX` everywhere |
| `util/BanglaDigits` | Renders/masks numbers in Bengali script |
| `util/VehicleOptions` | Brand list + vehicle-type cards (label + icon) for the signup form |

## Frontend tag library

Reusable JSP fragments under `webapp/WEB-INF/tags/`:

- `layout.tag` — page chrome (header, footer, links the compiled CSS)
- `input.tag` / `select.tag` / `textarea.tag` / `checkbox.tag` — form fields
- `uploadZone.tag` / `avatarUpload.tag` — file pickers with preview
- `otpBoxes.tag` — 6-digit OTP grid (with `<noscript>` fallback for JS-off browsers)
- `stepper.tag` / `stepNav.tag` / `reviewCardHeader.tag` / `fieldDisplay.tag` — wizard UI bits
- `icon.tag` — inline SVG icons (`car`, `truck`, `bike`, `phone`, `lock`, `eye`, …)
- `button.tag` / `passwordStrength.tag` — interactive controls

## Styling

- Tailwind CSS 4 source: `src/main/tailwind/app.css`
- Compiled output: `src/main/resources/static/css/app.css` (committed to git)
- Brand tokens: `--color-brand` (deep green `#0d3a2e`), `--color-brand-red`
- Bengali font: **Tiro Bangla** (matched by Unicode range), with **Hind Siliguri** for Latin fallback

Rebuild after editing JSPs/tags so new utility classes get scanned:

```bash
npm run build   # one-shot, minified
npm run dev     # watch mode
```
