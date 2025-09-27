# SafeEats

SafeEats helps people with food allergies and dietary restrictions discover restaurants they can trust. The platform pairs a FastAPI backend with an iOS (SwiftUI) client to deliver location-aware restaurant search, social recommendations, and menu intelligence tailored to each diner.

## Why SafeEats
- Build a personal profile with allergies, dietary preferences, and accessibility needs.
- Search for nearby restaurants that align with your profile using the Foursquare Places API plus curated SafeEats data.
- Review, rate, and discuss dishes with a community of friends and trusted reviewers.
- Let restaurant owners claim listings, upload verified menus, and engage with diners.
- Use OCR-powered menu scanning to flag potential allergens and surface accommodations.

## Architecture at a Glance
- **frontend/** &mdash; Native iOS SwiftUI app targeting iOS 18.2 (Xcode 15+). Handles authentication, location permissions, map-based search, reviews, collections, notifications, and business-owner tooling.
- **backend/** &mdash; FastAPI service backed by MongoDB. Integrates with Foursquare, AWS S3, SendGrid, and Twilio for search enrichment, media storage, messaging, and verification flows.
- **requirements.txt** &mdash; Python dependency lockfile (mirrors `backend/requirements.txt`; used if you prefer installing from the repo root).

> The backend exposes OpenAPI docs at `http://localhost:8000/docs`; the iOS client assumes the API is reachable at `http://localhost:8000` while running in the simulator.

## Repository Layout
```
SafeEats/
├── README.md                  # This file
├── backend/                   # FastAPI application, MongoDB integrations, background services
│   ├── api/endpoints/         # REST routes (users, auth, businesses, search, reviews, OCR, etc.)
│   ├── core/                  # Configuration, security helpers
│   ├── db/                    # Database connection and startup routines
│   ├── models/, schemas/      # Pydantic models for persistence and I/O validation
│   ├── services/              # Business logic, external service integrations
│   └── main.py                # FastAPI entry point
├── frontend/                  # SwiftUI iOS client
│   ├── SafeEats.xcodeproj     # Xcode project
│   ├── SafeEats/              # App sources (Views, ViewModels, Services, Utilities)
│   └── SafeEatsTests/*        # UI & unit test targets
└── requirements.txt           # Alternate path for installing backend deps
```

---

## Backend (FastAPI + MongoDB)

### Prerequisites
- Python 3.12
- MongoDB instance (local or Atlas); the app expects geospatial indexes for business searches
- Foursquare Places API key (for venue discovery)
- AWS S3 bucket plus API keys (for menu image storage)
- SendGrid API key (email password resets & reports)
- Twilio Voice account and verified caller ID (business owner phone verification)
- (Optional) Dropbox API token if you plan to use the legacy `db/connect_dropbox.py` utility

### Environment Variables
Create `backend/.env` with the following keys. Substitute your real credentials; keep quoted values if they contain special characters.

```bash
MONGODB_URI="mongodb+srv://<user>:<password>@<cluster>/"
MONGODB_NAME="safeeats"
FOURSQUARE_SECRET="fsq3..."               # API key used in the Authorization header
SENDGRID_KEY="SG.XXX"
TWILIO_SID="ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
TWILIO_AUTH_TOKEN="your-twilio-token"
TWILIO_PHONE="+15555555555"               # Verified outbound number
GEOCODE_KEY="your-geocode-provider-key"
AWS_ACCESS_KEY="AKIA..."
AWS_SECRET_KEY="your-secret"
AWS_REGION="us-east-1"
AWS_BUCKET_NAME="safeeats-menus"
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

> Keep secrets out of version control. The repo currently contains a hard-coded Dropbox token in `backend/db/connect_dropbox.py`; replace it with environment-driven configuration before production use.

### Install & Run
```bash
cd backend
python3.12 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
uvicorn main:app --reload
```

- The server starts on `http://localhost:8000`.
- Verify readiness with `GET /health` or explore routes at `http://localhost:8000/docs`.
- FastAPI’s lifespan handler will connect to MongoDB, clean duplicate businesses, and enforce unique indexes at startup.

### Key Services
- **User & Auth**: Email/password registration, JWT auth, password reset, trusted reviewer applications.
- **Profiles & Preferences**: Store allergies, dietary restrictions, and accessibility needs used by search.
- **Business Search**: Combines Foursquare results with SafeEats data, filters by cuisine/allergy match, and ranks results.
- **Reviews & Comments**: Voting, comment threads, meal tagging, accommodation tracking.
- **Collections & Friends**: Curate restaurant lists, send/accept friend requests, see a personalized feed.
- **Business Owners**: Claim listings, verify via Twilio phone calls, upload official menus, manage details.
- **Menu OCR**: EasyOCR + PyTorch pipeline uploads annotated menus to S3 and stores matches in MongoDB.

---

## Frontend (SwiftUI iOS App)

### Prerequisites
- macOS with Xcode 15 or later
- iOS 18.2 simulator or device profile (deployment target is 18.2)
- Backend running and reachable from the simulator (defaults to `http://localhost:8000`)

### Getting Started
1. Open `frontend/SafeEats.xcodeproj` in Xcode.
2. Select the `SafeEats` target and ensure signing is configured for your team.
3. If you are testing on a physical device, replace hard-coded `http://localhost:8000` URLs in the `ViewModels` folder with your Mac’s LAN IP or expose the backend via a tunnel (e.g., ngrok).
4. Grant the simulator/device location permissions when prompted; many views rely on CoreLocation.
5. Press **Run** to launch the app on the simulator.

### App Highlights
- **Authentication**: Separate flows for diners and business owners, including password recovery.
- **Onboarding**: Guided profile creation that syncs allergies and dietary preferences to the backend.
- **Search & Maps**: Location-aware discovery with cuisine and restriction filters, plus quick random picker.
- **Reviews & Feed**: Submit meals, upvote/downvote, follow friends, and view community activity.
- **Collections**: Save favorite spots and view details with SafeEats-coded accommodations.
- **Notifications**: Real-time friend requests, reports, and system alerts fetched from the backend.
- **Menu Scanner**: Upload photos or URLs; the app displays OCR-highlighted allergen risks returned by the API.

---

## Developing with Both Tiers
- Start the backend first so the iOS client can authenticate and fetch preferences during launch.
- Use the simulator for quickest setup; for device testing, ensure backend certificates and hostnames are trusted.
- When iterating on backend services, Hot Reload via `uvicorn --reload` will restart on code changes.
- MongoDB geospatial features are used for nearby searches; ensure your database has `2dsphere` indexes on `businesses.location.coordinates`.
- Keep large OCR dependencies (torch/easyocr) installed in the backend virtual environment; they are required for menu uploads.

## Troubleshooting
- **401 errors**: Confirm JWT tokens are stored in iOS `AuthViewModel` and the backend shares the same secret/expiry.
- **Search returns nothing**: Check that your `.env` contains a valid `FOURSQUARE_SECRET` and that MongoDB has seed data for cuisines.
- **Menu upload fails**: Verify AWS credentials and that the bucket allows `putObject` from your IAM user; torch must be available on the host.
- **Simulator cannot reach backend**: Use `http://127.0.0.1:8000` or your host IP if running through a proxy or VPN.
