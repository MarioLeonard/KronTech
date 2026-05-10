# Plan tehnic si UX: pagina de creare excursii

## Context inspectat

Aplicatia este Flutter si se afla in `frontend/`.

Structura actuala relevanta:

- `lib/main.dart` porneste aplicatia, incarca `.env`, Firebase, Hive si provider-ele principale.
- `lib/screens/main_shell.dart` contine shell-ul principal cu `AppBar`, `NavigationRail` pe ecrane late si `NavigationBar` pe mobil.
- Paginile principale sunt in `lib/screens/`: `HomeScreen`, `ProfileScreen`, `ChatScreen`, `SettingsScreen`.
- Exista un stil Material 3 definit in `lib/theme/app_theme.dart`, cu carduri la radius 8, culori principale albastru/oranj si dark mode activ implicit.
- Exista deja `http`, `provider` si `flutter_dotenv` in `pubspec.yaml`, deci integrarea initiala cu Gemini se poate face fara pachete noi obligatorii.
- Exista deja componente reutilizabile in `lib/components/`, dar modulele mai structurate sunt in `lib/features/onboarding/...`.

Recomandare arhitecturala: pentru pagina noua, folosim structura `features/trips/...`, ca sa nu aglomeram `screens/` si ca sa fie mai usor de extins ulterior cu salvare, istoric, retry, share etc.

## 1. Structura paginii si flow-ul utilizatorului

Pagina noua ar trebui sa fie accesibila din shell-ul principal, ca destinatie separata in navbar:

- Label propus: `Trips` sau `Create Trip`.
- Icon propus: `Icons.map_rounded` sau `Icons.route_rounded`.
- Pozitionare propusa in navbar: intre `Home` si `Profile`, deoarece este o actiune centrala a aplicatiei.

Flow recomandat:

1. Utilizatorul deschide pagina `Trips`.
2. Vede un formular clar pentru creare excursie:
   - camp pentru unul sau mai multe orase;
   - selectie data inceput;
   - selectie data final;
   - chip-uri multi-select pentru interese;
   - buton principal `Generate itinerary`.
3. Formularul valideaza local:
   - cel putin un oras;
   - data de inceput setata;
   - data finala setata;
   - data finala nu este inainte de data de inceput;
   - cel putin un interes selectat.
4. La apasarea butonului, UI-ul intra in loading state:
   - formularul ramane vizibil, dar butonul devine disabled;
   - se afiseaza progres si text scurt, de tip `Generating your itinerary...`.
5. Dupa raspuns:
   - daca raspunsul este valid, se afiseaza itinerariul in carduri organizate;
   - daca raspunsul este invalid sau gol, se afiseaza empty/error state cu retry;
   - daca API-ul da eroare, se afiseaza mesaj prietenos si optiune de reincercare.
6. Utilizatorul poate modifica inputurile si genera din nou.

UX recomandat pentru layout:

- Pe mobil: formularul sus, rezultatul sub formular, toate intr-un `SingleChildScrollView`.
- Pe tableta/desktop: layout in doua coloane:
  - stanga: formular compact/sticky;
  - dreapta: rezultate si sumar.
- Sa nu fie landing page sau hero. Pagina trebuie sa fie utilitara, orientata pe actiune.
- Cardurile sa respecte stilul curent: `Card`, radius 8, padding 16-24, iconografie Material.

## 2. Componente Flutter necesare

Componente principale:

- `TripCreationScreen`
  - ecranul principal al feature-ului;
  - compune formularul, loading/error states si rezultatul.

- `TripRequestForm`
  - gestioneaza campurile de input;
  - emite un `TripGenerationRequest` valid catre provider/controller.

- `CityMultiSelectField`
  - varianta simpla: `TextField` cu adaugare oras prin Enter/buton plus;
  - afiseaza orasele selectate ca `InputChip`;
  - ulterior poate fi inlocuit cu autocomplete sau catalog de orase.

- `TripDateRangeFields`
  - doua campuri readonly cu `showDatePicker`;
  - alternativ, `showDateRangePicker`, dar doua campuri sunt mai explicite pentru cerinta.

- `InterestChipsSelector`
  - `Wrap` cu `FilterChip`;
  - lista fixa de interese:
    - natura
    - cultura
    - mancare
    - relaxare
    - nightlife
    - shopping
    - aventura
    - istorie
    - familie/copii
    - buget redus
    - lux/premium

- `TripResultView`
  - primeste `TripItinerary`;
  - afiseaza sumarul, cazarea, zilele, restaurantele si notele.

- `TripSummaryCard`
  - cost total aproximativ;
  - distanta totala aproximativa;
  - durata totala aproximativa de deplasare;
  - disclaimer scurt: costurile si distantele sunt estimari.

- `TripDayCard`
  - card pentru fiecare zi;
  - contine data, titlu, costul zilei, distanta zilei si lista de activitati.

- `TripActivityCard`
  - interval orar;
  - nume activitate;
  - locatie;
  - descriere;
  - cost estimat;
  - distanta fata de punctul anterior;
  - durata estimata de deplasare.

- `AccommodationCard`
  - nume;
  - zona;
  - tip;
  - cost aproximativ/noapte;
  - link Booking/Airbnb sau link de cautare;
  - badge `suggestion` cand nu exista integrare API reala.

- `RestaurantCard`
  - nume;
  - tip bucatarie;
  - zona;
  - interval recomandat;
  - buget estimat;
  - motivul recomandarii.

- `TripEmptyState`
  - afisat inainte de prima generare sau cand AI-ul intoarce raspuns gol.

- `TripErrorState`
  - afiseaza mesajul de eroare si buton `Try again`.

State management:

- `TripCreationProvider extends ChangeNotifier`
  - status: `idle`, `loading`, `success`, `error`;
  - request curent;
  - itinerary generat;
  - error message;
  - metoda `generateTrip(TripGenerationRequest request)`.

## 3. Modelul de date pentru request si response

### Request intern

Model: `TripGenerationRequest`

Campuri:

- `List<String> cities`
- `DateTime startDate`
- `DateTime endDate`
- `List<TripInterest> interests`
- `String locale`, implicit `ro-RO`
- `String currency`, implicit `EUR` sau `RON`, de decis in produs
- `String distanceUnit`, implicit `km`

Enum propus: `TripInterest`

Valori:

- `nature`
- `culture`
- `food`
- `relaxation`
- `nightlife`
- `shopping`
- `adventure`
- `history`
- `familyKids`
- `lowBudget`
- `luxuryPremium`

Fiecare valoare ar trebui sa aiba label pentru UI in romana si valoare stabila pentru prompt/API.

### Response intern

Model principal: `TripItinerary`

Campuri:

- `String title`
- `String summary`
- `List<String> cities`
- `DateTime startDate`
- `DateTime endDate`
- `String currency`
- `TripCostSummary costSummary`
- `TripDistanceSummary distanceSummary`
- `List<TripDay> days`
- `List<AccommodationOption> accommodations`
- `List<RestaurantOption> restaurants`
- `List<String> assumptions`
- `List<String> warnings`

Model: `TripDay`

- `int dayNumber`
- `String date`
- `String title`
- `String city`
- `String summary`
- `num estimatedCost`
- `num estimatedDistanceKm`
- `String estimatedTransitDuration`
- `List<TripActivity> activities`
- `List<String> mealSuggestions`

Model: `TripActivity`

- `String timeRange`
- `String title`
- `String location`
- `String description`
- `num estimatedCost`
- `String costNote`
- `num distanceFromPreviousKm`
- `String travelTimeFromPrevious`
- `String transportMode`
- `List<String> tags`

Model: `AccommodationOption`

- `String name`
- `String city`
- `String area`
- `String type`
- `num estimatedNightlyCost`
- `String source`
- `String bookingSearchUrl`
- `String airbnbSearchUrl`
- `bool isSearchSuggestion`
- `String note`

Model: `RestaurantOption`

- `String name`
- `String city`
- `String area`
- `String cuisine`
- `String recommendedFor`
- `num estimatedMealCost`
- `String note`

Model: `TripCostSummary`

- `num estimatedTotal`
- `num estimatedActivitiesTotal`
- `num estimatedFoodTotal`
- `num estimatedAccommodationTotal`
- `String note`

Model: `TripDistanceSummary`

- `num estimatedTotalKm`
- `String estimatedTotalTransitDuration`
- `String note`

Important: toate modelele trebuie sa aiba `fromJson`, iar parsing-ul trebuie sa fie defensiv. Orice camp lipsa trebuie tratat prin fallback, nu prin crash.

## 4. Integrarea Gemini Flash

### Unde se tine API key-ul

Varianta minima pentru implementare initiala:

- `frontend/.env`
- cheie: `GEMINI_API_KEY=...`
- citire prin `flutter_dotenv`, deja configurat in `main.dart`.

Limitare: in aplicatiile mobile, o cheie pusa in client poate fi extrasa. Pentru productie, varianta recomandata este backend proxy:

- Flutter trimite request-ul catre backend-ul propriu;
- backend-ul tine `GEMINI_API_KEY` in environment securizat;
- backend-ul apeleaza Gemini si returneaza JSON-ul validat.

Recomandare pragmatica:

- pentru prototip/demo: API key in `.env`;
- pentru productie: endpoint backend, de exemplu `POST /api/trips/generate/`.

### Cum se face request-ul

Serviciu propus: `GeminiTripService`

Responsabilitati:

- construieste promptul pe baza `TripGenerationRequest`;
- apeleaza endpoint-ul Gemini `generateContent`;
- cere raspuns JSON prin `response_mime_type: application/json`, daca folosim API-ul direct;
- decodeaza raspunsul;
- valideaza structura minima;
- returneaza `TripItinerary`.

Folosire HTTP:

- se poate folosi pachetul `http`, deja existent;
- request timeout recomandat: 30-60 secunde;
- retry manual doar pentru erori tranzitorii, nu pentru raspunsuri invalide.

Model recomandat:

- `gemini-2.0-flash` sau modelul Flash disponibil/configurat la momentul implementarii.
- Numele modelului ar trebui pus intr-o constanta sau in `.env`, de exemplu `GEMINI_MODEL=gemini-2.0-flash`.

### Cum se parseaza raspunsul

Parsing recomandat:

1. Se extrage textul JSON din raspunsul Gemini.
2. Se face `jsonDecode`.
3. Se verifica daca root-ul este `Map<String, dynamic>`.
4. Se parseaza cu `TripItinerary.fromJson`.
5. Se valideaza minim:
   - `days` nu este gol;
   - fiecare zi are cel putin o activitate;
   - exista `costSummary`;
   - exista `distanceSummary`.
6. Daca lipsesc campuri optionale, UI-ul afiseaza fallback:
   - `Cost not available`;
   - `Distance estimate unavailable`;
   - `Suggestion only`.

### Loading, error si empty state

Status propus: `TripGenerationStatus`

- `idle`
  - afiseaza formular + empty state discret.
- `loading`
  - buton disabled;
  - indicator circular/liniar;
  - skeleton cards optional.
- `success`
  - afiseaza `TripResultView`.
- `error`
  - afiseaza card de eroare cu:
    - mesaj scurt;
    - detalii tehnice doar in debug/log;
    - buton `Try again`.
- `empty`
  - optional, daca raspunsul AI este valid JSON, dar nu contine itinerariu util.

Mesaje recomandate:

- API key lipsa: `Configuratia Gemini lipseste. Verifica GEMINI_API_KEY.`
- network error: `Nu am putut genera excursia acum. Verifica conexiunea si incearca din nou.`
- invalid AI response: `Raspunsul primit nu a avut formatul asteptat. Incearca din nou.`

## 5. Prompt exact pentru Gemini Flash

Promptul trebuie sa ceara strict JSON si sa includa faptul ca Booking/Airbnb sunt doar sugestii/linkuri de cautare daca nu exista API reala.

Prompt propus:

```text
You are a travel planning assistant. Generate a practical, day-by-day trip itinerary.

Return ONLY valid JSON. Do not include markdown, comments, explanations, or text outside the JSON object.

User request:
- Cities: {{cities}}
- Start date: {{startDate}}
- End date: {{endDate}}
- Main interests: {{interests}}
- Locale/language: Romanian
- Currency: {{currency}}
- Distance unit: kilometers

Important requirements:
- Organize the itinerary by day.
- Include recommended activities with approximate time ranges.
- Include approximate cost for each activity and each day.
- Include approximate distances in kilometers between objectives.
- Include approximate travel duration between locations.
- Include recommended accommodation options.
- For Booking or Airbnb, if you do not have a real API integration or live availability, mark them clearly as search suggestions and provide search URLs, not claims of availability.
- Include restaurants or places to eat.
- Costs, distances, and durations are estimates and must be marked as approximate.
- Prefer realistic pacing. Do not overload days.
- Avoid inventing exact live prices or availability.
- If information is uncertain, include it in assumptions or warnings.

JSON schema:
{
  "title": "string",
  "summary": "string",
  "cities": ["string"],
  "startDate": "YYYY-MM-DD",
  "endDate": "YYYY-MM-DD",
  "currency": "string",
  "costSummary": {
    "estimatedTotal": 0,
    "estimatedActivitiesTotal": 0,
    "estimatedFoodTotal": 0,
    "estimatedAccommodationTotal": 0,
    "note": "string"
  },
  "distanceSummary": {
    "estimatedTotalKm": 0,
    "estimatedTotalTransitDuration": "string",
    "note": "string"
  },
  "days": [
    {
      "dayNumber": 1,
      "date": "YYYY-MM-DD",
      "title": "string",
      "city": "string",
      "summary": "string",
      "estimatedCost": 0,
      "estimatedDistanceKm": 0,
      "estimatedTransitDuration": "string",
      "activities": [
        {
          "timeRange": "string",
          "title": "string",
          "location": "string",
          "description": "string",
          "estimatedCost": 0,
          "costNote": "string",
          "distanceFromPreviousKm": 0,
          "travelTimeFromPrevious": "string",
          "transportMode": "walking/public_transport/taxi/car/train/other",
          "tags": ["string"]
        }
      ],
      "mealSuggestions": ["string"]
    }
  ],
  "accommodations": [
    {
      "name": "string",
      "city": "string",
      "area": "string",
      "type": "hotel/apartment/hostel/guesthouse/other",
      "estimatedNightlyCost": 0,
      "source": "Booking/Airbnb/Search suggestion/Other",
      "bookingSearchUrl": "string",
      "airbnbSearchUrl": "string",
      "isSearchSuggestion": true,
      "note": "string"
    }
  ],
  "restaurants": [
    {
      "name": "string",
      "city": "string",
      "area": "string",
      "cuisine": "string",
      "recommendedFor": "breakfast/lunch/dinner/snack",
      "estimatedMealCost": 0,
      "note": "string"
    }
  ],
  "assumptions": ["string"],
  "warnings": ["string"]
}

Validation rules:
- Return at least one day.
- Return at least two activities per day unless the trip duration makes that impossible.
- Use numeric values for costs and distances.
- Use Romanian for all human-readable strings.
- Keep URLs as search URLs when live availability cannot be verified.
```

Observatie: la implementare, placeholders precum `{{cities}}` vor fi inlocuiti cu valori JSON-safe, nu prin concatenare fragila.

## 6. Design-ul cardurilor

Design general:

- Sa foloseasca `Card` cu padding 16.
- Radius 8, conform temei existente.
- Iconuri Material:
  - calendar pentru zile;
  - route/map pentru distante;
  - payments pentru costuri;
  - hotel pentru cazare;
  - restaurant pentru masa;
  - warning/info pentru disclaimere.
- Sa evite blocuri foarte lungi de text; informatia trebuie scanata usor.

### Card pentru fiecare zi

Continut:

- Header:
  - `Day 1`
  - data;
  - oras;
  - titlu scurt.
- Sumar:
  - 1-2 randuri.
- Metrics row:
  - cost estimat zi;
  - distanta estimata;
  - durata deplasari.
- Lista de `TripActivityCard`.

Pe mobil, metrics row poate deveni `Wrap`.

### Card pentru activitati

Continut:

- interval orar ca badge mic;
- titlu activitate;
- locatie;
- descriere scurta;
- chips pentru tags;
- rand compact:
  - cost;
  - distanta fata de anterior;
  - durata pana acolo;
  - mod transport.

Activitatile trebuie afisate cronologic.

### Card pentru cazare

Continut:

- nume;
- oras/zona;
- tip cazare;
- cost estimat pe noapte;
- sursa;
- butoane/linkuri:
  - `Booking search`;
  - `Airbnb search`;
- badge vizibil: `Sugestie, nu disponibilitate verificata`.

Fara integrare API reala, UI-ul nu trebuie sa sugereze ca exista disponibilitate confirmata.

### Card pentru restaurante

Continut:

- nume;
- oras/zona;
- bucatarie;
- recomandat pentru mic dejun/pranz/cina/snack;
- cost estimat masa;
- nota scurta.

Restaurantele pot fi afisate:

- fie global, intr-o sectiune `Restaurants`;
- fie grupate pe zile, daca Gemini returneaza meal suggestions detaliate.

### Sumar costuri si distante

Card sus in rezultate:

- cost total estimat;
- activitati;
- mancare;
- cazare;
- distanta totala;
- durata totala de deplasare;
- nota de estimare.

Acest card trebuie sa fie primul in rezultate, ca utilizatorul sa inteleaga rapid ordinul de marime al excursiei.

## 7. Riscuri si limitari

- Costurile sunt aproximative.
  - Gemini nu are garantat acces la preturi live.
  - UI-ul trebuie sa marcheze clar estimarile.

- Distantele si duratele sunt aproximative.
  - Fara integrare Google Maps/Places/Distance Matrix, distantele pot fi inexacte.
  - O etapa viitoare ar putea valida distantele cu un API dedicat.

- Booking/Airbnb pot necesita API reala.
  - Fara API, aplicatia trebuie sa genereze doar linkuri de cautare.
  - Nu trebuie afisate preturi sau disponibilitati ca fiind verificate.

- Raspunsul AI poate fi invalid sau incomplet.
  - Este obligatorie validarea JSON.
  - UI-ul trebuie sa suporte campuri lipsa.
  - Serviciul trebuie sa intoarca erori controlate, nu exceptii necontrolate in UI.

- API key in client este risc de securitate.
  - Acceptabil pentru demo rapid.
  - Pentru productie, trebuie mutata in backend.

- Latenta poate fi mare.
  - Trebuie loading state clar.
  - Butonul de generare trebuie disabled cat timp exista request activ.

- Continutul poate contine recomandari nepotrivite sau inventate.
  - Promptul trebuie sa ceara asumptii/warnings.
  - UI-ul trebuie sa arate un disclaimer scurt.

## 8. Pasi concreti de implementare

Ordinea recomandata:

1. Adaugare modele de date pentru request/response.
2. Adaugare enum interese si mapper pentru label-uri UI.
3. Adaugare `GeminiTripService` cu:
   - citire `.env`;
   - construire prompt;
   - request HTTP;
   - parsing defensiv;
   - erori controlate.
4. Adaugare `TripCreationProvider`.
5. Adaugare UI formular:
   - orase;
   - date;
   - interese;
   - validari;
   - submit.
6. Adaugare UI rezultate:
   - sumar;
   - carduri zile;
   - activitati;
   - cazari;
   - restaurante;
   - warnings/assumptions.
7. Integrare pagina in `MainShell`.
8. Adaugare provider in `main.dart`, daca alegem provider global.
   - Alternativ, provider local in `TripCreationScreen`, ca scope-ul este limitat.
9. Adaugare chei in `.env.example`, daca exista sau daca se creeaza.
10. Testare manuala:
    - input valid;
    - fara orase;
    - data finala inainte de inceput;
    - fara interese;
    - API key lipsa;
    - raspuns invalid;
    - layout mobil si desktop.
11. Optional: teste unitare pentru parsing si validare.

## 9. Fisiere care ar trebui create sau modificate

### Fisiere noi recomandate

- `frontend/lib/features/trips/domain/trip_interest.dart`
  - enum interese + label-uri.

- `frontend/lib/features/trips/domain/trip_generation_request.dart`
  - model request.

- `frontend/lib/features/trips/domain/trip_itinerary.dart`
  - model principal response.

- `frontend/lib/features/trips/domain/trip_day.dart`
  - model zi.

- `frontend/lib/features/trips/domain/trip_activity.dart`
  - model activitate.

- `frontend/lib/features/trips/domain/accommodation_option.dart`
  - model cazare.

- `frontend/lib/features/trips/domain/restaurant_option.dart`
  - model restaurant.

- `frontend/lib/features/trips/domain/trip_summary.dart`
  - modele pentru cost si distanta.

- `frontend/lib/features/trips/data/gemini_trip_service.dart`
  - integrarea Gemini.

- `frontend/lib/features/trips/presentation/controllers/trip_creation_provider.dart`
  - state management.

- `frontend/lib/features/trips/presentation/screens/trip_creation_screen.dart`
  - pagina principala.

- `frontend/lib/features/trips/presentation/widgets/trip_request_form.dart`
  - formular input.

- `frontend/lib/features/trips/presentation/widgets/city_multi_select_field.dart`
  - selectare orase.

- `frontend/lib/features/trips/presentation/widgets/trip_date_range_fields.dart`
  - selectie date.

- `frontend/lib/features/trips/presentation/widgets/interest_chips_selector.dart`
  - selectare interese.

- `frontend/lib/features/trips/presentation/widgets/trip_result_view.dart`
  - container rezultate.

- `frontend/lib/features/trips/presentation/widgets/trip_summary_card.dart`
  - sumar costuri/distante.

- `frontend/lib/features/trips/presentation/widgets/trip_day_card.dart`
  - card zi.

- `frontend/lib/features/trips/presentation/widgets/trip_activity_card.dart`
  - card activitate.

- `frontend/lib/features/trips/presentation/widgets/accommodation_card.dart`
  - card cazare.

- `frontend/lib/features/trips/presentation/widgets/restaurant_card.dart`
  - card restaurant.

- `frontend/lib/features/trips/presentation/widgets/trip_error_state.dart`
  - stare eroare.

- `frontend/lib/features/trips/presentation/widgets/trip_empty_state.dart`
  - stare initiala/goala.

### Fisiere existente de modificat

- `frontend/lib/screens/main_shell.dart`
  - import pentru `TripCreationScreen`;
  - adaugare destinatie noua in lista `destinations`.

- `frontend/lib/main.dart`
  - daca provider-ul este global: adaugare `ChangeNotifierProvider` pentru `TripCreationProvider`;
  - daca provider-ul este local in screen, nu este obligatoriu.

- `frontend/pubspec.yaml`
  - probabil nu necesita dependinte noi pentru prima versiune;
  - optional, se poate adauga un pachet pentru URL launching daca linkurile Booking/Airbnb trebuie deschise extern, de exemplu `url_launcher`.

- `frontend/.env`
  - adaugare `GEMINI_API_KEY`;
  - optional `GEMINI_MODEL`.

- `frontend/.env.example`
  - daca exista sau va fi creat, trebuie documentate cheile fara valori reale.

## Decizii recomandate inainte de implementare

1. Moneda implicita: `EUR` sau `RON`.
2. Integrare Gemini direct din Flutter pentru demo sau prin backend pentru productie.
3. Label navbar: `Trips`, `Create Trip` sau varianta in romana.
4. Daca rezultatele generate se salveaza local/in backend sau raman doar in sesiunea curenta.
5. Daca linkurile Booking/Airbnb se deschid in browser extern; pentru asta ar trebui adaugat `url_launcher`.

## Recomandare finala

Pentru prima implementare, as merge pe varianta:

- feature separat in `lib/features/trips`;
- provider local in `TripCreationScreen`;
- Gemini direct prin `GeminiTripService` si `.env`, doar pentru MVP;
- raspuns JSON strict si parsing defensiv;
- linkuri Booking/Airbnb marcate clar ca sugestii de cautare;
- UI in carduri Material 3, integrat in shell-ul existent.

Dupa validarea UX-ului, mutarea apelului Gemini in backend ar fi urmatorul pas important pentru securitate si control.
