import { db } from "./config.js";
import {
  getDocs,
  collection,
} from "https://www.gstatic.com/firebasejs/11.4.0/firebase-firestore.js";

async function getfiles() {
  console.log("fetching");
  try {
    const filecollection = collection(db, "files");
    const filedocs = await getDocs(filecollection);

    filedocs.forEach((fdoc) => {
      const data = fdoc.data();
      console.log("fetching again");

      const { file, fileExtension, fileName } = data;

      if (fileExtension === "pdf") {
        console.log("pdf found");

        displayPDF(file, fileName);
      } else if (fileExtension === "jpg" || fileExtension === "jpeg") {
        console.log("images found");

        displayImage(file, fileName);
      }
    });
  } catch (error) {
    console.error(error);
  }
}
function displayPDF(base64, filename) {
    const pdfDiv = document.querySelector('.pdfs');
  
    const byteCharacters = atob(base64);
    const byteNumbers = Array.from(byteCharacters, char => char.charCodeAt(0));
    const byteArray = new Uint8Array(byteNumbers);
    const blob = new Blob([byteArray], { type: 'application/pdf' });
    const blobUrl = URL.createObjectURL(blob);
  
    const wrapper = document.createElement('div');
    const link = document.createElement('a');
    link.href = blobUrl;
    link.target = '_blank';
    link.rel = 'noopener noreferrer';
    link.innerText = `Open PDF in new tab: ${filename}`;
  
    wrapper.appendChild(link);
    pdfDiv.appendChild(wrapper);
  }
  
  

function displayImage(base64, filename) {
  const imgDiv = document.querySelector(".images");
  const img = document.createElement("img");
  img.src = `data:image/jpeg;base64,${base64}`;
  img.alt = filename;
  img.style.maxWidth = "100%";
  img.style.height = "auto";

  const wrapper = document.createElement("div");
  const label = document.createElement("p");
  label.innerText = `Image: ${filename}`;
  wrapper.appendChild(label);
  wrapper.appendChild(img);
  imgDiv.appendChild(wrapper);
}

// const sampleBase64 = 'JVBERi0xLjQKJc...'; // full base64 of a small PDF
// displayPDF(sampleBase64, 'Test PDF');

getfiles();
