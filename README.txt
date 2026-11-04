SALVATION STORE INVENTORY — SETUP GUIDE
=======================================

WHAT IS INCLUDED
- index.html: the website interface and JavaScript.
- schema.sql: database tables, permissions, and safe sale/restock functions.
- README.txt: these instructions.

IMPORTANT
The site uses a shared online Supabase database. The HTML file alone is not enough.
Complete the database setup and add your project's URL/key before publishing.
No login is used, as requested. Anyone with the link can view and change records.
For a real shop, a login/PIN or other access protection is safer.

STEP 1 — CREATE THE ONLINE DATABASE
1. Visit https://supabase.com and create an account.
2. Create a new project named Salvation Store Inventory.
3. Choose a database password and keep it somewhere safe.
4. Wait for the project to finish creating.
5. In your project, open SQL Editor.
6. Choose New query.
7. Open the schema.sql file from this folder in a text editor, copy ALL its contents,
   paste into the SQL Editor, then press Run.
8. Make sure the query finishes successfully. If it shows an error, stop and fix that
   before publishing.

STEP 2 — COPY YOUR PROJECT URL AND PUBLIC/ANON KEY
1. In Supabase, open Project Settings, then API (or the project's Connect/API section).
2. Copy the Project URL.
3. Copy the anon/public key. Depending on the Supabase dashboard version, it may be
   labelled "anon" or "publishable".
4. Never use the secret/service_role key in a website. Do not share your database
   password or service_role key.

STEP 3 — CONNECT THE WEBSITE TO THE DATABASE
1. Open index.html using a text editor such as Notepad or Visual Studio Code.
2. Find these two lines near the bottom of the file:
   const SUPABASE_URL = "PASTE_YOUR_SUPABASE_PROJECT_URL_HERE";
   const SUPABASE_ANON_KEY = "PASTE_YOUR_SUPABASE_ANON_KEY_HERE";
3. Replace the first placeholder with your Project URL, keeping the quotation marks.
   Example format only: const SUPABASE_URL = "https://your-project-id.supabase.co";
4. Replace the second placeholder with your anon/public key, keeping quotation marks.
5. Save index.html.

STEP 4 — TEST IT ON YOUR COMPUTER
1. Open index.html in Chrome or Edge while connected to the internet.
2. If it says "Connected • shared stock is live", the database connection works.
3. Add a test product, e.g. Test item, price 10, unit box, quantity 20, low-stock alert 5.
4. Record a sale of 2. The quantity should become 18.
5. Open the same page in another browser or phone. The same stock should appear.
6. Restock 5. Both devices should update.
7. Delete the test product only if you have not recorded transactions for it; this version
   deliberately does not offer deletion to protect transaction history.

STEP 5 — PUBLISH THE WEBSITE SO STAFF CAN OPEN A LINK
One simple option is Netlify:
1. Visit https://www.netlify.com and create an account.
2. Sign in and open the manual deploy / Netlify Drop option (the dashboard labels can change).
3. Drag the folder containing the saved index.html into the deploy area. You may upload the
   index.html file/site folder depending on what the current Netlify interface requests.
4. Netlify will give you a website link. Open it on your phone and test the functions.
5. Keep the Supabase project running; Netlify hosts the page, Supabase stores the data.
6. Send the same website link to every staff member. Everyone uses the same shared stock.

IF THE HOSTING SERVICE WILL NOT ACCEPT THE FOLDER
You can use GitHub Pages instead: create a repository, upload index.html, enable Pages in
repository Settings, and open the published link. Never upload schema.sql if you do not want
staff to see the setup instructions; it is not required for the website to run.

HOW IT WORKS
- Products, prices, units, quantities, and low-stock thresholds are stored online.
- Sales subtract stock; restocks add stock.
- Every sale/restock is recorded in transaction history.
- Dashboard reports units sold today, this week, and this month.
- Prices are displayed only; no revenue or profit calculations are made.
- The stock is shared across all shops/phones; no separate shop stock is created.
- Live updates require internet access on each device.
- Sales are processed inside the database to prevent stock going below zero even when
  two people attempt sales at nearly the same time.

SECURITY WARNING
Because you asked for no login, the database policies intentionally allow public access.
Anyone who gets the website link can edit products and change stock through the site.
Do not put the link on a public social media page. If you later want only your employees
to use it, add authentication/PIN access and tighten the database permissions.

TROUBLESHOOTING
- "Setup needed": the URL/key placeholders were not replaced or not saved.
- "Could not connect": confirm the URL and anon/public key, check internet, and confirm
  schema.sql ran successfully.
- Products fail to save: confirm schema.sql ran successfully and check Supabase logs.
- Another phone does not update: both phones need internet and must be using the same link.
- Never put a service_role/secret key into index.html.
