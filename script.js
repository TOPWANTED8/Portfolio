// ===== SECTION HIGHLIGHT FUNCTION =====
let isManualClick = false;

function highlightSection(sectionId) {
    // Remove highlight from all sections
    document.querySelectorAll('.group, .about-wrapper').forEach(group => {
        group.classList.remove('highlight');
    });
    
    // Remove active from all nav-dots
    document.querySelectorAll('.nav-dot').forEach(dot => {
        dot.classList.remove('active');
    });
    
    // Add highlight to clicked section
    let targetSection;
    if (sectionId === '#about') {
        targetSection = document.querySelector('.about-wrapper');
    } else {
        targetSection = document.querySelector(sectionId);
    }
    
    if (targetSection) {
        targetSection.classList.add('highlight');
        isManualClick = true;
        
        // Add active to corresponding nav-dot
        const sectionName = sectionId.replace('#', '');
        const navDot = document.querySelector(`.nav-item[data-section="${sectionName}"] .nav-dot`);
        if (navDot) {
            navDot.classList.add('active');
        }
        
        // Scroll to section smoothly
        targetSection.scrollIntoView({ behavior: 'smooth' });
        
        // Reset flag after scroll completes
        setTimeout(() => {
            isManualClick = false;
        }, 1000);
    }
}

// Auto-highlight section when scrolling into view
window.addEventListener('scroll', () => {
    // Skip auto-highlight if user just clicked a button
    if (isManualClick) return;
    
    let current = '';
    const scrollY = window.scrollY;
    const windowHeight = window.innerHeight;
    const documentHeight = document.documentElement.scrollHeight;
    
    // Check about section first
    const aboutSection = document.querySelector('.about-wrapper');
    if (aboutSection && scrollY < aboutSection.offsetTop + aboutSection.clientHeight - 200) {
        current = 'about';
    } else {
        document.querySelectorAll('.group').forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.clientHeight;
            
            if (scrollY >= sectionTop - 200 && scrollY < sectionTop + sectionHeight) {
                current = section.getAttribute('id');
            }
        });
        
        // If scrolled to bottom, ensure pricing is active
        if (scrollY + windowHeight >= documentHeight - 100) {
            current = 'pricing';
        }
    }
    
    // Remove highlight from all
    document.querySelectorAll('.group, .about-wrapper').forEach(section => {
        section.classList.remove('highlight');
    });
    
    // Remove active from nav-dots
    document.querySelectorAll('.nav-dot').forEach(dot => {
        dot.classList.remove('active');
    });
    
    if (current) {
        const element = document.getElementById(current) || document.querySelector('.about-wrapper');
        if (element) {
            element.classList.add('highlight');
            // Add active to nav-dot
            const navDot = document.querySelector(`.nav-item[data-section="${current}"] .nav-dot`);
            if (navDot) {
                navDot.classList.add('active');
            }
        }
    }
});

// ===== NAV DOT CLICK =====
document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', () => {
        const section = item.getAttribute('data-section');
        highlightSection('#' + section);
    });
});


// ===== COPY DISCORD FUNCTION =====
function copyDiscord(event) {
    event.preventDefault(); // Prevent navigation
    const discordLink = "https://discord.com/users/930292577196965938";
    navigator.clipboard.writeText(discordLink).then(() => {
        const btn = event.target;
        const originalText = btn.textContent;
        btn.textContent = "Copied to Clipboard!";
        setTimeout(() => {
            btn.textContent = originalText;
        }, 2000);
    }).catch(err => {
        console.error('Failed to copy: ', err);
    });
}

// ===== BUTTON CUSTOMIZATION =====
// Edit these values to customize button appearance

const buttonConfig = {
    // ===== SOCIAL BUTTONS (Discord/Twitter) =====
    // Button size: change padding
    padding: '40px 78px',      // e.g., '15px 25px' for larger buttons
    fontSize: '14px',          // e.g., '16px' for bigger text
    
    // Background opacity (0-1)
    bgOpacity: '0.9',          // e.g., '0.7' for more transparent
    
    // Colors
    discordColor: '#b269fc',   // Discord purple
    twitterColor: '#a0c9ff',   // Twitter blue
    
    // Hover scale effect (1 = no scale, 1.2 = 20% larger)
    hoverScale: '1.15',        // e.g., '1.25' for bigger scale effect
    
    // ===== MAIN GRID BUTTONS (Scripting Code, Media, Projects, Pricing) =====
    mainButtonBg: '#1f1f1f',             // Button background color
    mainButtonBorder: '#555',            // Button border color
    mainButtonFontSize: '20px',          // Button text size
    mainButtonHoverBg: '#2f2f2f',        // Hover background color
    mainButtonHoverBorder: '#84ff7b',    // Hover border color (green)
    mainButtonHoverScale: '1.02'         // Hover scale effect
};

// Apply custom button settings
// Social buttons
document.documentElement.style.setProperty('--btn-padding', buttonConfig.padding);
document.documentElement.style.setProperty('--btn-font-size', buttonConfig.fontSize);
document.documentElement.style.setProperty('--btn-bg-opacity', buttonConfig.bgOpacity);
document.documentElement.style.setProperty('--discord-color', buttonConfig.discordColor);
document.documentElement.style.setProperty('--twitter-color', buttonConfig.twitterColor);
document.documentElement.style.setProperty('--btn-hover-scale', buttonConfig.hoverScale);

// Main grid buttons
document.documentElement.style.setProperty('--main-btn-bg', buttonConfig.mainButtonBg);
document.documentElement.style.setProperty('--main-btn-border', buttonConfig.mainButtonBorder);
document.documentElement.style.setProperty('--main-btn-font-size', buttonConfig.mainButtonFontSize);
document.documentElement.style.setProperty('--main-btn-hover-bg', buttonConfig.mainButtonHoverBg);
document.documentElement.style.setProperty('--main-btn-hover-border', buttonConfig.mainButtonHoverBorder);
document.documentElement.style.setProperty('--main-btn-hover-scale', buttonConfig.mainButtonHoverScale);

// ===== TWINKLING STARS =====

const starsContainer = document.getElementById("stars-container");

const starCount = 180;

for(let i = 0; i < starCount; i++){

    let star = document.createElement("div");

    star.className = "star";

    let size = Math.random() * 3 + 1;

    star.style.width = size + "px";
    star.style.height = size + "px";

    star.style.top = Math.random() * window.innerHeight + "px";
    star.style.left = Math.random() * window.innerWidth + "px";

    star.style.animationDuration = (Math.random() * 3 + 2) + "s";

    starsContainer.appendChild(star);
}

// SHOOTING STARS

function createShootingStar(){

    let shootingStar = document.createElement("div");

    shootingStar.className = "shooting-star";

    shootingStar.style.top =
        Math.random() * (window.innerHeight / 2) + "px";

    shootingStar.style.left =
        Math.random() * window.innerWidth + "px";

    starsContainer.appendChild(shootingStar);

    setTimeout(() => {
        shootingStar.remove();
    }, 1500);
}

// RANDOM SHOOTING STAR

setInterval(() => {

    if(Math.random() > 0.5){
        createShootingStar();
    }

}, 500);

// ===== LOAD CODE FUNCTION =====

async function loadCode(path){
    try{
        const response = await fetch(path);
        if(!response.ok) throw new Error('Network response was not ok');

        const text = await response.text();
        const codeDisplay = document.getElementById("codeDisplay");
        if(!codeDisplay) return;

        const extension = path.split('.').pop().toLowerCase();
        const luaLanguages = ['lua', 'luau'];

        if (luaLanguages.includes(extension)) {
            codeDisplay.className = 'language-lua';
            const result = hljs.highlight(text, { language: 'lua', ignoreIllegals: true });
            codeDisplay.innerHTML = result.value;
        } else {
            codeDisplay.className = '';
            codeDisplay.textContent = text;
        }
    }catch(error){
        const codeDisplay = document.getElementById("codeDisplay");
        if(codeDisplay) {
            codeDisplay.className = 'language-lua';
            codeDisplay.textContent = "Failed to load script.";
        }
        console.error('Error loading code:', error);
    }
}

function toggleVideos(){
    const extraVideos = document.querySelectorAll('.video-item.extra-video');
    const button = document.getElementById('viewMoreBtn');
    if(!extraVideos.length || !button) return;
    // Ensure dataset is initialized
    if (typeof button.dataset.expanded === 'undefined') button.dataset.expanded = 'false';

    const isExpanded = button.dataset.expanded === 'true'; // current state
    // If currently expanded, hide extras; if collapsed, show extras
    extraVideos.forEach(video => {
        video.classList.toggle('hidden-video', isExpanded);
    });

    // Toggle the scroll wrapper expanded class to allow scrolling when opened
    const wrapper = document.getElementById('videoScrollWrapper');
    if (wrapper) wrapper.classList.toggle('expanded', !isExpanded);

    // Update button text and state
    button.textContent = isExpanded ? 'View More Videos' : 'View Less Videos';
    button.dataset.expanded = (!isExpanded).toString();
}

// ===== VIDEO MODAL =====
function openVideoModal(src){
    const modal = document.getElementById('videoModal');
    const frameContainer = modal?.querySelector('.video-modal-frame');
    if(!modal || !frameContainer) return;

    // Create iframe with autoplay
    frameContainer.innerHTML = `<iframe src="${src}?autoplay=1" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen style="width:100%;height:80vh;border-radius:8px;"></iframe>`;
    modal.classList.remove('hidden-video');
}

function closeVideoModal(){
    const modal = document.getElementById('videoModal');
    const frameContainer = modal?.querySelector('.video-modal-frame');
    if(!modal || !frameContainer) return;
    // Remove iframe to stop playback
    frameContainer.innerHTML = '';
    modal.classList.add('hidden-video');
}

// Initialize video item click handlers and modal close
document.addEventListener('DOMContentLoaded', () => {
    const btn = document.getElementById('viewMoreBtn');
    if(btn && typeof btn.dataset.expanded === 'undefined') btn.dataset.expanded = 'false';

    document.querySelectorAll('.video-item').forEach(item => {
        item.style.cursor = 'pointer';
        item.addEventListener('click', (e) => {
            // Avoid opening modal when clicking inside an iframe
            if (e.target.tagName.toLowerCase() === 'iframe') return;
            const src = item.dataset.videoSrc;
            if (src) openVideoModal(src);
        });
    });

    const modal = document.getElementById('videoModal');
    const modalClose = document.getElementById('videoModalClose');
    if(modalClose) modalClose.addEventListener('click', closeVideoModal);
    if(modal) modal.addEventListener('click', (e) => { if (e.target === modal) closeVideoModal(); });
});

function toggleProjects(){
    const extraProjects = document.querySelectorAll('.project-card.extra-project');
    const button = document.getElementById('viewMoreProjectsBtn');
    if(!extraProjects.length || !button) return;

    const isExpanded = button.dataset.expanded === 'true';
    extraProjects.forEach(project => {
        project.classList.toggle('hidden-project', isExpanded);
    });

    button.textContent = isExpanded ? 'View More Projects' : 'View Less Projects';
    button.dataset.expanded = (!isExpanded).toString();
}