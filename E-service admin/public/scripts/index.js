import { auth, db } from "./config.js";
import { sessionchecker } from "./sessionchecker.js";
import { signInWithEmailAndPassword } from "https://www.gstatic.com/firebasejs/11.4.0/firebase-auth.js";
import {
  getDocs,
  collection,
} from "https://www.gstatic.com/firebasejs/11.4.0/firebase-firestore.js";


async function login(username, password) {
  console.log("sample");
  try {
    const admincollection = collection(db, "admins");
    console.log(admincollection);
    const admindocs = await getDocs(admincollection);
    console.log(admindocs);
    admindocs.forEach((user) => {
      const data = user.data();
      if (username === data.username && password === data.password) {
        console.log("user found");
        signInWithEmailAndPassword(auth, data.email, data.password).then(
          (userCredential) => {
            Swal.fire({
              title: "Log in successful",
              text: `Welcome ${data.username}`,
              icon: "success",
              confirmButtonText: "Continue",
            }).then(() => {
              window.location.assign("/dashboard");
            });
          }
        );
      } else if (username === data.username && password != data.password) {
        console.log("Password incorrect");
        Swal.fire({
          title: "Error logging you in",
          text: `Password incorrect for ${data.username}`,
          icon: "error",
          confirmButtonText: "Try again",
        });
      } else {
        Swal.fire({
          title: "User does not exists",
          text: `The user ${data.username} does not exists`,
          icon: "error",
          confirmButtonText: "Try again",
        });
      }
      console.log(user.data());
    });
  } catch (error) {
    console.error(error);
  }
}

const loginform = document.getElementById("login-form");
loginform.addEventListener("submit", (e) => {
  e.preventDefault();

  const username = loginform["username"].value;
  const password = loginform["password"].value;
  login(username, password);
});
//   console.log(loginform);
