import { auth } from "./config.js";

import { onAuthStateChanged } from "https://www.gstatic.com/firebasejs/11.4.0/firebase-auth.js";

export function sessionchecker() {
  onAuthStateChanged(auth, (user) => {
    if (user) {
      console.log("User is logged in");
      // window.location.assign("/dashboard");
    } else {
      // window.location.assign("/");
    }
  });
}
