# Coder Code-Server
## Enhanced


Hi, I've made some changes to coder's code-server (which I love) to improve some aspects of the user experience for me and my friends.

I'll write the dates of when I make changes for now and what was changed, maybe make this file more professional later.

- December 2, 2025
Files changed:
src/node/routes/login.ts
src/node/http.ts
src/node/util.ts

Changes were made to prevent code-server previous login sessions to work after 6 hours since first authentication
Why? because tokens are generated based off code-server's login password the token doesn't change
AND hopefully kept the "good" version of vs code that doesn't have the new UI or co-pilot bs