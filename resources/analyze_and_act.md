# threat analysis & action plan

## sources

- website
- company profile on pages like linkedin
  - job openings
- names of employees
  - their social profiles
  - and profiles on StackOverflow/Reddit/...
- weitere Tools nutzen, um alle verfügbaren Infos zu finden
  - Recon-ng (https://github.com/lanmaster53/recon-ng)
  - Maltego (www.maltego.com)
  - Shodan search engine (www.shodan.io)
  - TinEye (www.tineye.com)
  - Google
Dorks (see https://en.wikipedia.org/wiki/Google_hacking)

## public vulnerability databases

-  https://nvd.nist.gov and https://nvd.nist.gov/general/nvd-dashboard

## scanning tools

- nmap scan
- Greenbone's open-source edition OpenVAS
- SCAP and OpenSCAP (owasp.org) scan
- ClamAV, maldet, rootkit-hunter

## penetration testing

- use results from previous scanning
- phishing, physical access, sql injection, mitm, xss, buffer overflow
- exploit db: zap, metasploit
- red-blue team testing
