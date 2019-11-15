; Ce programme fait jouer un jeu de bataille navale. Le jeu est joue par un seul
; joueur. Le joueur commence par placer des navires sur une grille, puis il leur
; tire dessus.
;
; Auteur: Wiliam Chretien,        Code permanent: CHRW15109406
; Auteur: Ricardo Ruy Valle-Mena, Code permanent: VALR29129407
mainLoop:CALL    initTab
         STRO    MSG_BIEN,d
         CALL    printTab
         STRO    MSG_ENTR,d
         CALL    verifBat 
         ;call    feuVolnt
         ;stro    MSG_FIN,d
         ;call    stri
         ;cpa     '\n',i
         ;breq    mainLoop
         STOP



;//A VERIFIER SI ON INCREMENTE DE DEUX A PLACE DE UN
; Initialise le tableau
initTab: LDX     0,i
; loop pour remplir chaque case du tableau avec un '~'
ITLoop:  CPX     NB_CASES,i
         BRGE    ITFin
         LDBYTEA '~',i
         STBYTEA TABLEAU,x
         ADDX    1,i
         BR      ITLoop
ITFin:   RET0



; Affiche le tableau
printTab:SUBSP   8,i
         STRO    MSG_COLN,d
         LDX     0,i
;Loop pour afficher chaque valeur des rangees
PTLoopRn:CHARO   '\n',i
         ADDX    1,i
         STX     PTRangee,s  ;affiche la position de rangee + 1 (car on commence a 0) + '|'
         SUBX    1,i         ;
         CPX     NB_RANGE,i  ;
         BRGE    PTFin       ;
         DECO    PTRangee,s  ;
         CHARO   '|',i       ;
         LDA     0,i
;Loop pour afficher chaque valeur du tableau par rapport a la rangee et colonne
PTLoopCl:CPA     NB_COLN,i   ;for (A=0; A <= 18; A++)
         BRGE    finCl       
         STA     PTTmpA,s    ;sauvegarde les valeurs de A et X
         STX     PTTmpX,s    ;
         LDA     NB_COLN,i
         CALL    mult        ;multiplie l'accumulateur par le registre d'index
         ADDA    PTTmpA,s    ;NB_COLN * X + A
         STA     PTTmpM,s    ;
         LDX     PTTmpM,s    ;
         CHARO   TABLEAU,x   ;print(TABLEAU[NB_COLN * X + A])
         LDA     PTTmpA,s    ;restore A et X
         LDX     PTTmpX,s    ;
         ADDA    1,i         
         BR      PTLoopCl
;
finCl:   CHARO   '|',i       ;la rangee a ete imprimer au complet, on incremente X pour passer a la prochaine
         ADDX    1,i
         BR      PTLoopRn  
;
PTFin:   ADDSP   8,i
         RET0
; utilise pour sauvegarder et restaurer l'indexe et l'accumulateur
PTTmpA:  .EQUATE 0
PTTmpX:  .EQUATE 2
; utilise pour calculer la multiplication
PTTmpM:  .EQUATE 4
; garde la valeur de la rangee a laquelle on est, pour l'imprimer
PTRangee:.EQUATE 6



; Verifie que les bateaux entres sont conformes a l'enonce.
verifBat:CALL    creeDesc    ;init le descripteur global avec l'entre de l'utilisateur
         LDX     0,i
loopVer: CALL    verDescB    ;la methode retourne 0 si une description de bateau est mauvaise, 1 si bonne
         CPA     1,i         ;
         BREQ    batVal      ;si bonne on continue plus loin
         STRO    MSG_EBAT,d  ;sinon affiche un msg d'erreur et reinitialise les variables locales
         LDA     0,i         ;
         STA     nbBateau,s  ;
         STA     separBat,s  ;
         LDX     0,i         ;
         BR      verifBat    ;
batVal:  LDA     nbBateau,s  ;la description du bateau est valide
         ADDA    1,i         ;nbBateau++
         STA     nbBateau,s  ;
         ADDX    4,i         ;X += 4
         LDBYTEA separBat,sx  ;separBat = desc[A]
         ADDX    1,I         ;X += 1
         CPA     '\n',i      ;si separBat != '\n' il y a au moins une autre description de bateaux
         BRNE    loopVer     ;
;/////////////////
;//A CONTINUER ICI
;/////////////////
nbBateau:.EQUATE 0
separBat:.EQUATE 2



;Verifie la description d'un bateau, retourne 0 par l'accumulateur si un bateau n'est pas conforme et 1 si oui.
verDescB:SUBSP   2,i         ;Sauvegarde X
         STX     verTmpX,s   ;
         LDX     0,i
         LDBYTEA desc,x      ;compare la premiere lettre de la description du bateau soit la grandeur
         CPA     'p',i       ;
         BREQ    GValide     ;
         CPA     'm',i       ;
         BREQ    GValide     ;
         CPA     'g',i       ;
         BREQ    GValide     ;
         BR      descBatF
GValide: ADDX    2,i         ;grandeur est valide, verifie maintenant la deuxieme lettre soit l'orientation
         LDBYTEA desc,x      ;
         CPA     'h',i       ;
         BREQ    OValide     ;
         CPA     'v',i       ;
         BREQ    OValide     ;
         BR      descBatF
OValide: ADDX    2,i         ;orientation valide, verifie maintenant la troisieme lettre soit la colonne
         LDBYTEA desc,x      ;
         CPA     'A',i       ;
         BRLT    descBatF    ;
         CPA     'R',i       ;
         BRGT    descBatF    ;
         ADDX    2,i         ;colonne valide, verifie maintenant la quatrieme lettre soit la rangee
         LDBYTEA desc,x      ;
         CPA     '1',i       ;
         BRLT    descBatF    ;
         CPA     '9',i       ;
         BRGT    descBatF    ;
         BR      descBatV    
descBatF:LDA     0,i         ;un echec de verification met 0 dans l'accumulateur
         BR      finVerDB    ;
descBatV:LDA     1,i         ;un succes de verification met 1 dans l'accumulateur
finVerDB:LDX     verTmpX,s   ;restore la valeur d'origine a X
         ADDSP   2,i         ;libere la variable locale
         RET0
verTmpX: .EQUATE 0



;Lecteur de string, s'arrete lorsqu'on pese sur ENTREE.
;Utilise variable global `desc` pour mettre le resultat
creeDesc:LDX     0,i
loopDesc:CPX     STR_LEN,i
         BRGE    descFin 
         CHARI   desc,x
         LDBYTEA desc,x
         ADDX    2,i
         CPA     '\n',i
         BRNE    loopDesc
descFin: RET0



; Multiplie deux valeurs donnees par l'index et l'accumulateur
; Le resultat sera place dans l'accumulateur .
mult:    SUBSP   4,i         
         STX     multTmpX,s  ;sauvegarde X et A
         STA     multTmpA,s  ;
         CPX     0,i         ;verifie si un operand est 0, si oui on retourne immediatement un 0
         BREQ    multi0      ;
         CPA     0,i         ;
         BREQ    multi0      ;
         LDX     1,i
multLoop:CPX     multTmpX,s
         BRGE    multFin
         ADDA    multTmpA,s
         ADDX    1,i
         BR      multLoop
multi0:  LDA     0,i         ;retourne 0 lorsqu'un des deux operand est 0
multFin: LDX     multTmpX,s  ;restore la valeur d'origine de X
         ADDSP   4,i         
         RET0
multTmpX:.EQUATE 0
multTmpA:.EQUATE 2



; Constantes globales representant les messages qui peuvent etre affiches
MSG_BIEN:.ASCII  "Bienvenue au jeu de bataille navale!\n\n\x00"
MSG_ENTR:.ASCII  "Entrer la description et la position des bateaux\n"
         .ASCII  "selon le format suivant, separes par des espaces:\n"
         .ASCII  "taille[p/m/g] orientation[h/v] colonne [A-R] rangee[1-9]\n"
         .ASCII  "ex: ghC4 mvM2 phK9\n\x00"
MSG_TIR: .ASCII  "Feu a volonote!\n(entrer les coups a tirer: colonne[A-R] "
         .ASCII  "rangee [1-9])\nex: A3 I5 M3\n\x00"
MSG_FIN: .ASCII  "Vous avez aneanti la flotte!\nAppuyer sur <Enter> pour jouer "
         .ASCII  "a nouveau ou\nn'importe quelle autre saisie pour quitter.\n\x00"
MSG_BYE: .ASCII  "Au revoir!\x00"

; Messages d'erreur possibles
MSG_ETIR:.ASCII  "Erreur! Mauvais placement de tirs, veuillez recommencer.\n\x00"
MSG_EBAT:.ASCII  "Erreur! Mauvais placement de bateaux, veuillez recommencer.\n\x00"

; Noms des colonnes pour l'affichage du tableau
MSG_COLN:.ASCII  "  ABCDEFGHIJKLMNOPQR\x00"

; Constantes du tableau
NB_RANGE:.EQUATE 9
NB_COLN: .EQUATE 18
NB_CASES:.EQUATE 162
STR_LEN: .EQUATE 900

; Tableau servant au jeu
TABLEAU: .BLOCK  162
; Descripteur global pour STRI
desc:    .BLOCK  900 
         .END
