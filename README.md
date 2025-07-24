# 🍬 candyNDS - Joc Candy Crush per Nintendo DS (NDS)

Projecte per l'assignatura **Computadors**  
Grau en Enginyeria Informàtica - ETSE - URV

---

## 📖 Descripció

**candyNDS** és una adaptació del joc clàssic tipus Candy Crush per a la consola portàtil Nintendo DS.  
El joc està programat en C utilitzant la llibreria libnds per gestionar gràfics, interrupcions i entrada tàctil.

Aquest projecte forma part de la pràctica del curs de **Computadors** i està desenvolupat per a l’arquitectura ARM de la Nintendo DS.

---

## ⚙️ Funcionament general

El programa principal està contingut a `candy2_main.c` i gestiona el flux del joc:  

- Inicialització de gràfics i variables globals  
- Configuració d’interrupcions per temporitzadors  
- Bucle principal amb les següents fases:  
  - Inicialització de nivells i tauler  
  - Caiguda d’elements en el tauler (gelatines)  
  - Processament d’entrada tàctil per fer moviments  
  - Actualització de puntuacions, moviments i nivell  
  - Gestió del canvi de nivell quan es completa el nivell actual  

La matriu de joc representa el tauler amb gelatines, punts, moviments i nivell actual.

---

## 📁 Estructura del projecte

- `candy2_main.c` : Programa principal i control de joc  
- `candy2_incl.h` : Capçaleres i definicions comunes  
- Altres fitxers ARM: implementació de funcions específiques per a la NDS  
- Recursos gràfics i mapes per nivells  

---

## 🕹️ Controls

- Pantalla tàctil per moure gelatines  
- Tecla **Y**: activar/desactivar desplaçament de fons  
- Tecla **B**: forçar canvi de nivell  
- Tecla **A**: confirmar canvi de nivell  

---

## 📌 Notes

- El joc utilitza temporitzadors per controlar la velocitat de caiguda dels elements  
- El sistema d’interrupcions està configurat per gestionar el temporitzador i actualitzar el joc  
- La semilla per números aleatoris es fixa amb el temps actual a l’inici del programa  

---

