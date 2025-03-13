import { signOut } from "https://www.gstatic.com/firebasejs/11.4.0/firebase-auth.js";
import { auth } from "./config.js";

const logoutbtn = document.getElementById('logout');

logoutbtn.addEventListener('click', ()=>{
    signOut(auth)
    .then(() => {
      Swal.fire({
        title: "Sample",
        text: "Log out successful",
        icon: "success",
      }).then(async (result) => {
        location.assign("/");
      });
    });
});


