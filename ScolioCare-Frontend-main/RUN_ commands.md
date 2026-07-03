# Run ScolioCare Frontend

These commands run the Flutter frontend beside the local backend.

## Current Setup

- Backend URL: `http://localhost:8081`
- Frontend web URL: `http://127.0.0.1:8082`
- Flutter SDK location: `..\..\.tooling\flutter`

## One-Time Path Fix

The project path contains spaces, which can break Flutter/Dart native asset tooling on Windows. Map the workspace to a temporary drive letter before running Flutter:

```powershell
subst X: "D:\Gam3a\Gam3a Fourth level\Grad phase 2\App"
```

After that, use the `X:\` path for frontend commands.

## Install Dependencies

```powershell
cd X:\ScolioCare-Frontend-main\ScolioCare-Frontend-main
X:\.tooling\flutter\bin\flutter.bat pub get
```

## Run Frontend On Web

```powershell
cd X:\ScolioCare-Frontend-main\ScolioCare-Frontend-main
X:\.tooling\flutter\bin\flutter.bat run -d web-server --web-hostname 127.0.0.1 --web-port 8082 --dart-define=API_BASE_URL=http://localhost:8081
```

Open:

```text
http://127.0.0.1:8082
```

## Run In Chrome Directly

Use this if you want Flutter to launch Chrome itself:

```powershell
cd X:\ScolioCare-Frontend-main\ScolioCare-Frontend-main
X:\.tooling\flutter\bin\flutter.bat run -d chrome --dart-define=API_BASE_URL=http://localhost:8081
```

## Useful Checks

```powershell
X:\.tooling\flutter\bin\flutter.bat doctor -v
X:\.tooling\flutter\bin\flutter.bat devices
```

## Stop The App

If running in the same terminal, press:

```text
q
```

If it was started in the background, close the Dart/Flutter process from Task Manager or run:

```powershell
Get-Process | Where-Object { $_.ProcessName -like "*flutter*" -or $_.ProcessName -like "*dart*" }
```

Then stop the needed process by ID:

```powershell
Stop-Process -Id <PROCESS_ID>
```

## Web Testing Vs Mobile Testing

Web testing is enough for checking:

- Login/register API calls
- General backend integration
- Routing and screen flow
- Most form validation
- Basic UI layout
- Data loading from the backend

Mobile testing is still needed for:

- Camera behavior
- Image picker behavior
- Secure storage behavior on Android/iOS
- Sensors and scoliometer features
- File upload edge cases from a real device
- Android/iOS permissions
- Mobile-specific layout issues
- Physical-device networking, where the backend URL usually must be your PC LAN IP instead of `localhost`

For final QA, test both web and a real Android device or emulator. Web is good for fast backend integration testing, but it is not a full replacement for mobile testing for this app.



backend run commands:
-------------------------
cd "D:\Gam3a\Gam3a Fourth level\Grad phase 2\App\scoliocare-backend-experment\ScolioCare-ML-Model-main\ai_service"

.\.venv\Scripts\python.exe -m uvicorn app.main:app --host 0.0.0.0 --port 8000
.\mvnw.cmd spring-boot:run   

docker compose up -d redis      