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
         ADDA    PTTmpA,s    ;A = NB_COLN * X + A
         STA     PTTmpM,s    ;
         LDX     PTTmpM,s    ;X = A
         CHARO   TABLEAU,x   ;print(TABLEAU[X])
         LDA     PTTmpA,s    ;restore les valeurs d'origine a A et X
         LDX     PTTmpX,s    ;
         ADDA    1,i         
         BR      PTLoopCl
finCl:   CHARO   '|',i       ;la rangee a ete imprimer au complet, on incremente X pour passer a la prochaine
         ADDX    1,i
         BR      PTLoopRn  
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
verifBat:SUBSP   16,i
         BR      iniVarVB 
loopVBat:CALL    creeDesc    ;init un descripteur par le tas
         STX     descBat,s   ;range le pointeur du descripteur
         LDX     0,i
loopVdes:LDA     descBat,s   ;met le pointeur du descripteur dans A pour appeller verDescB
         CALL    verDescB    ;la methode retourne 0 si une description de bateau est mauvaise, 1 si bonne
         CPA     1,i         ;
         BREQ    batVal      ;si bonne on continue plus a batVal
         STRO    MSG_EBAT,d  ;sinon affiche un msg d'erreur et reinitialise les variables locales
iniVarVB:LDA     0,i         ;
         STA     nbBateau,s  ;
         BR      loopVBat    ; 
batVal:  LDA     nbBateau,s  ;la description du bateau est valide
         ADDA    1,i         ;nbBateau++
         STA     nbBateau,s  ;
         ADDX    4,i         ;X += 4
         LDBYTEA descBat,sxf ;separBat = desc[A]
         ADDX    1,i         ;X += 1
         CPA     '\n',i      ;si X += 5 != '\n' il y a au moins une autre description de bateaux
         BRNE    loopVdes    ; 
         LDA     0,i
         STA     iterA,s
; Loop pour placer les bateaux
batPLoop:LDA     iterA,s     ;for (A = 0; A < nbBateau; A++)
         CPA     nbBateau,s  ;
         BREQ    finBat
         LDX     5,i         ;on retrouve chaque premier caractere d'une description de bateau grace a X = A * 5 mot
         CALL    mult        ;
         STA     resMultA,s  ;
         LDX     resMultA,s  ;X = descBat[A*5 mot]
; Change le char de la grandeur en son nombre de cases relatif puis le place sur le stack pour la fonction placeBat
         LDA     0,i
         LDBYTEA descBat,sxf
         CPA     'p',i
         BREQ    nbCases1 
         CPA     'm',i
         BREQ    nbCases3
         LDA     5,i
         STA     nbCasesT,s   ;
         BR      signOrie
nbCases1:LDA     1,i
         STA     nbCasesT,s   ;
         BR      signOrie
nbCases3:LDA     3,i
         STA     nbCasesT,s   ;
; Change le char de l'orientation en un caractere plus representatif pour l'affichage dans le tableau et le place sur le stack pour la fonction placeBat
signOrie:LDA     iterA,s     ;on retrouve chaque deuxieme caractere d'une description de bateau grace a X = A * 5 + 1 
         LDX     5,i         ;
         CALL    mult        ;
         STA     resMultA,s  ;
         LDX     resMultA,s  ;
         ADDX    1,i         ;
         LDA     0,i
         LDBYTEA descBat,sxf
         CPA     'h',i
         BREQ    changChO
         STA     charOriT,s  ;
         BR      chNbCln 
changChO:LDBYTEA '>',i
         STA     charOriT,s  ;
; Change le char de la colonne en sa valeur decimal et le place sur le stack pour la fonction placeBat
chNbCln: LDA     iterA,s     ;on retrouve chaque troisieme caractere d'une description de bateau grace a X = A * 5 + 2
         LDX     5,i        ;
         CALL    mult        ;
         STA     resMultA,s  ;
         LDX     resMultA,s  ;
         ADDX    2,i         ;
         LDA     0,i
         LDBYTEA descBat,sxf
         SUBA    'A',i
         STA     nbColnT,s    ;
; Change le char de la rangee en sa valeur decimal et le place sur le stack pour la fonction placeBat
         LDA     iterA,s     ;on retrouve chaque quatrieme caractere d'une description de bateau grace a X = A * 5 + 3
         LDX     5,i        ;
         CALL    mult        ;
         STA     resMultA,s  ;
         LDX     resMultA,s  ;
         ADDX    3,i         ;
         LDA     0,i
         LDBYTEA descBat,sxf
         SUBA    '1',i
         STA     nbRangeT,s  ;
         LDA     iterA,s     ;
         ADDA    1,i         ;
         STA     iterA,s     ;A++
         CALL    placeBat    ;tous les parametre ont ete place sur la pile, on peut appeller la fonction placeBat
         BR      batPLoop    ;
finBat:  ADDSP   16,i
         RET0
descBat: .EQUATE 0           ;contient le pointeur de l'objet du descripteur
nbBateau:.EQUATE 2           ;le nombre de bateau valides
resMultA:.EQUATE 4           ;le resultat le la fonction mult
iterA:   .EQUATE 6           ;sauvegarde l'iterateur quand on a besoin de l'accumulateur pour autre chose
nbCasesT:.EQUATE 8           ;nombre cases place en parametre par le stack pour placeBat
charOriT:.EQUATE 10          ;caractere orientation place en parametre par le stack pour placeBat
nbColnT: .EQUATE 12          ;nombre colonnes place en parametre par le stack pour placeBat
nbRangeT:.EQUATE 14          ;nombre rangees place en parametre par le stack pour placeBat



; Place un bateau dans le tableau, ne retourne rien
; IN: Pile[10] = int nbCases 
;     Pile[12] = char orientation
;     Pile[14] = int colonne
;     Pile[16] = int rangee
placeBat:CALL    verPBat     ;verPBat(int nbCases, char orientation, int colonne, int rangee)
         SUBSP   4,i
         CPA     0,i
         BREQ    finPBat 
         LDA     0,i
         LDBYTEA 4,s
         CPA     'v',i
         BREQ    grandVer
         LDA     0,i
         STA     iterA2,s
loopGraH:CPA     2,s
         BRGE    finPBat
         LDA     8,s
         LDX     NB_COLN,i
         CALL    mult
         ADDA    iterA2,s
         ADDA    6,s
         STA     resPTmp,s
         LDX     resPTmp,s
         LDBYTEA 4,s
         STBYTEA TABLEAU,x
         LDA     iterA2,s
         ADDA    1,i
         BR      loopGraH
grandVer:LDA     0,i
         STA     iterA2,s
loopGraV:CPA     2,s
         BRGE    finPBat
         LDA     8,s
         LDX     NB_COLN,i
         CALL    mult
         ADDA    6,s
         STA     resPTmp,s
         LDA     iterA2,s
         CALL    mult
         ADDA    resPTmp,s
         STA     resPTmp,s
         LDX     resPTmp,s
         LDBYTEA 4,s
         STBYTEA TABLEAU,x
         LDA     iterA2,s
         ADDA    1,i
         BR      loopGraV     
finPBat: RET4
iterA2:  .EQUATE 0
resPTmp: .EQUATE 2



; Verifie si un bateau peut etre entre dans le tableau et qu'il ne rentre pas en collision avec un autre
; IN: Stack[16] = int nbCases
;     Stack[18] = char orientation
;     Stack[20] = int colonne
;     Stack[22] = int rangee
; OUT: 1 par l'accumulateur si oui, 0 si non
verPBat: SUBSP   4,i         ;reserve variables locales
         LDX     0,i
         STX     iterX,s
loopVPB: LDX     iterX,s     ;for (X = 0; X < nbCases; X++)
         CPX     16,s        ;
         BRGE    finVerVa    ;
         LDA     18,s        ;verifie si le caractere est verticale ou horizontal
         CPA     'v',i       ;
         BREQ    VPBVert     ;
         LDA     20,s        ;verHorsC(colonne + iterX, rangee)
         ADDA    iterX,s     ;
         LDX     22,s        ;
         CALL    verHorsC    ;parametres passes par indexes 
         CPA     0,i         ;
         BREQ    placBInv    ;si verHorsC retourne 0 alors placement invalide
         LDA     22,s        ;return TABLEAU[colonne + mult(rangee, NB_COLN) + iterX] != '~' 
         LDX     NB_COLN,i   ;
         CALL    mult        ;
         ADDA    20,s        ;
         ADDA    iterX,s     ;
         STA     resMX,s     ;
         LDX     resMX,s     ;
         LDA     0,i         ;
         LDBYTEA TABLEAU,x   ;
         CPA     '~',i       ;
         BRNE    placBInv    ;
         LDX     iterX,s     ;
         ADDX    1,i         ;X ++
         STX     iterX,s     ;
         BR      loopVPB     
VPBVert: LDA     20,s        ;verHorsC(colonne, rangee + iterX)
         LDX     22,s        ;
         ADDX    1,i         ;
         CALL    verHorsC    ;parametres passes par indexes
         CPA     0,i         ;
         BREQ    placBInv    ;si verHorsC retourne 0 alors placement invalide
         LDA     22,s        ;
         LDX     NB_COLN,i   ;TABLEAU[colonne + mult(rangee, NB_COLN) + mult(iterX, NB_COLN)] != '~'
         CALL    mult        ;
         ADDA    20,s        ;
         STA     resMX,s     ;
         LDA     iterX,s     ;
         CALL    mult        ;
         ADDA    resMX,s     ;
         STA     resMX,s     ;
         LDX     resMX,s     ;
         LDA     0,i         ;
         LDBYTEA TABLEAU,x   ;
         CPA     '~',i       ;
         BRNE    placBInv    ;
         LDX     iterX,s     ;X++
         ADDX    1,i         ;
         STX     iterX,s     ;   
         BR      loopVPB     ;
placBInv:LDA     0,i         ;placement invalide, retourne 0 par l'accumulateur
         BR      finVerPB    ;
finVerVa:LDA     1,i         ;placement valide, retourne 1 par l'accumulateur
finVerPB:RET4
iterX:   .EQUATE 0
resMX:   .EQUATE 2



; Verifie si une position colonne/rangee est a l'interieur du jeu.
; IN: A = position en colonne
;     X = position en rangee
; OUT: 1 par l'accumulateur si la position est a l'interieur du tableau, 0 si non.
verHorsC:SUBSP   8,i
         STA     clnTmp,s
         STX     rangTmp,s
         LDX     NB_COLN,i   ;resTmp2 = mult(rangee, NB_COLN) + colonne
         LDA     rangTmp,s
         CALL    mult        ;
         ADDA    clnTmp,s    ;
         STA     resTmp2,s   ;
         LDA     rangTmp,s   ;return resTmp2 < mult(rangee + 1, NB_COLN)
         ADDA    1,i         ;
         CALL    mult        ;
         CPA     resTmp2,s   ;
         BRLE    horsC
         LDA     rangTmp,s   ;return resTmp2 >= mult(rangee - 1, NB_COLN)
         SUBA    1,s         ;
         CALL    mult        ;
         ADDA    NB_COLN,i   ;
         CPA     resTmp2,s   ;
         BRGT    horsC       
         LDA     resTmp2,s   ;return resTmp2 < NB_CASES
         CPA     NB_CASES,i  ;
         BRGE    horsC       
         CPA     0,i         ;return resTmp2 >= 0
         BRLT    horsC
         LDA     1,i         ;met 1 dans l'accumulateur si toute les comparaisons ont retournees vrai
         BR      finVHC    
horsC:   LDA     0,i         ;met 0 dans l'accumulateur si une comparaison a echoue.
finVHC:  ADDSP   8,i         ;libere les variables locales
         RET0
clnTmp:  .EQUATE 0
rangTmp: .EQUATE 2
resTmp1: .EQUATE 4
resTmp2: .EQUATE 6



; Verifie la description d'un bateau.
; Precondition: A doit contenir l'addresse du descripteur.
; Retourne: 0 par l'accumulateur si un bateau n'est pas conforme et 1 si oui.
verDescB:SUBSP   4,i         ;reserve variables locales descTmp et verTmpX
         STX     verTmpX,s   ;sauvegarde X dans verTmpX
         STA     descTmp,s   ;met pointeur dans descTmp
         LDA     0,i
         LDBYTEA descTmp,sxf ;compare la premiere lettre de la description du bateau soit la grandeur 
         CPA     'p',i       ;
         BREQ    GValide     ;
         CPA     'm',i       ;
         BREQ    GValide     ;
         CPA     'g',i       ;
         BREQ    GValide     ;
         BR      descBatF    ;si aucun matche, lettre invalide donc on va a descBatF
GValide: ADDX    1,i         ;grandeur est valide, verifie maintenant la deuxieme lettre soit l'orientation
         LDBYTEA descTmp,sxf ;
         CPA     'h',i       ;
         BREQ    OValide     ;
         CPA     'v',i       ;
         BREQ    OValide     ;
         BR      descBatF    ;si aucun matche, lettre invalide donc on va a descBatF
OValide: ADDX    1,i         ;orientation valide, verifie maintenant la troisieme lettre soit la colonne
         LDBYTEA descTmp,sxf ;
         CPA     'A',i       ;
         BRLT    descBatF    ;si descTmp[X] < 'A', la colonne est invalide
         CPA     'R',i       ;
         BRGT    descBatF    ;si descTmp[X] > 'R', la colonne est invalide
         ADDX    1,i         ;colonne valide, verifie maintenant la quatrieme lettre soit la rangee
         LDBYTEA descTmp,sxf ;
         CPA     '1',i       ;
         BRLT    descBatF    ;si descTmp[X] < '1', la rangee est invalide
         CPA     '9',i       ;
         BRGT    descBatF    ;si descTmp[X] > '9', la rangee est invalide
         BR      descBatV    ;description du bateau est valide
descBatF:LDA     0,i         ;un echec de verification met 0 dans l'accumulateur
         BR      finVerDB    ;
descBatV:LDA     1,i         ;un succes de verification met 1 dans l'accumulateur
finVerDB:LDX     verTmpX,s   ;restore la valeur d'origine a X
         ADDSP   4,i         ;libere les variables locales
         RET0
descTmp: .EQUATE 0
verTmpX: .EQUATE 2



; Lecteur de string, s'arrete lorsqu'on pese sur ENTREE.
; Utilise le tas pour cree le tableau
; Retourne le pointeur du tableau par l'index
creeDesc:SUBSP   2,i         ;reserve variable locale desc
         LDA     STR_LEN,i   ;passe le nombre d'octets qu'aura le tableau a new
         CALL    new         ;
         STX     desc,s      ;range le pointeur retourne par new
         LDX     0,i
         LDA     0,i
loopDesc:CPX     STR_LEN,i   ;for (X = 0; X < STR_LEN; X += 2)
         BRGE    descFin     ;
         CHARI   desc,sxf    ;    desc[x] = CHARI
         LDBYTEA desc,sxf    ;
         ADDX    1,i         ;
         CPA     '\n',i      ;    if (X = '\n')
         BRNE    loopDesc    ;        break
descFin: LDX     desc,s      ;retourne le pointeur du tableau par X
         ADDSP   2,i         ;libere la variable locale desc
         RET0
desc:    .EQUATE 0



; Operateur new
; Precondition: A contient nombre d'octets
; Postcondition: X contient un pointeur vers le tas
new:     LDX     hpPtr,d  ;pointeur retourne 
         ADDA    hpPtr,d
         STA     hpPtr,d
         RET0
hpPtr:   .ADDRSS heap



; Multiplie deux valeurs donnees par l'index et l'accumulateur
; Le resultat sera place dans l'accumulateur .
mult:    SUBSP   4,i         ;reserve variables locales
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
multi0:  LDA     0,i         
multFin: LDX     multTmpX,s  ;restore la valeur d'origine de X
         ADDSP   4,i         ;libere vairables locales
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

heap:    .BLOCK  1
         .END
