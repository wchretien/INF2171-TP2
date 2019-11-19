; Ce programme fait jouer un jeu de bataille navale. Le jeu est joue par un seul
; joueur. Le joueur commence par placer des navires sur une grille, puis il leur
; tire dessus.
;
; Auteur: Wiliam Chretien,        Code permanent: CHRW15109406
; Auteur: Ricardo Ruy Valle-Mena, Code permanent: VALR29129407
;
; Controle l'operation du programme.
mainLoop:SUBSP   2,i         ;reserve variable locale
         CALL    initTab     
         STRO    MSG_BIEN,d
         CALL    printTab
         STRO    MSG_ENTR,d
         CALL    verifBat 
         CALL    feuVolnt
         STRO    MSG_FIN,d
         CALL    creeDesc
         STX     descLTmp,s
         LDX     0,i
         LDBYTEA descLTmp,sxf
         CPA     '\n',i
         BREQ    mainLoop
         STRO    MSG_BYE,d 
         STOP
descLTmp:.EQUATE 0           ;contient pointeur du descripteur cree lors d'une sollicitation d'une nouvelle partie


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
         LDA     PTTmpA,s    ;
         LDX     PTTmpX,s    ;
         ADDA    1,i         ;A++
         BR      PTLoopCl
finCl:   CHARO   '|',i       ;la rangee a ete imprimer au complet, on incremente X pour passer a la prochaine
         ADDX    1,i         ;
         BR      PTLoopRn  
PTFin:   ADDSP   8,i
         RET0
PTTmpA:  .EQUATE 0           ;contient la valeur de l'index utilise avec A
PTTmpX:  .EQUATE 2           ;contient la valeur 
PTTmpM:  .EQUATE 4           ;utilise pour calculer la multiplication
PTRangee:.EQUATE 6           ;garde la valeur de la rangee a laquelle on est, pour l'imprimer



; Verifie que les bateaux entres sont conformes a l'enonce.
verifBat:SUBSP   16,i        ;reserve variables locales
         BR      iniVarVB 
loopVBat:CALL    creeDesc    ;init un descripteur par le tas
         STX     descBat,s   ;range le pointeur du descripteur
         LDX     0,i
loopVdes:LDA     descBat,s   ;met le pointeur du descripteur dans A pour appeller verDescB
         CALL    verDescB    ;la methode retourne 0 si une description de bateau est mauvaise, 1 si bonne
         CPA     1,i         ;
         BREQ    batVal      ;si bonne on peut continuer
         STRO    MSG_EBAT,d  ;sinon affiche un msg d'erreur et reinitialise nbBateau
iniVarVB:LDA     0,i         ;
         STA     nbBateau,s  ;
         BR      loopVBat    ; 
batVal:  LDA     nbBateau,s  ;la description du bateau est valide
         ADDA    1,i         ;nbBateau++
         STA     nbBateau,s  ;
         ADDX    4,i         ;X += 4
         LDBYTEA descBat,sxf ;A = desc[X]
         ADDX    1,i         ;X += 1
         CPA     '\n',i      ;si A != '\n' il y a au moins une autre description de bateaux
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
; Change le char de la grandeur en son nombre de cases relatif puis le place sur la pile pour la fonction placeBat
         LDA     0,i
         LDBYTEA descBat,sxf
         CPA     'p',i
         BREQ    nbCases1 
         CPA     'm',i
         BREQ    nbCases3
         LDA     5,i
         STA     nbCasesT,s   
         BR      signOrie
nbCases1:LDA     1,i
         STA     nbCasesT,s   
         BR      signOrie
nbCases3:LDA     3,i
         STA     nbCasesT,s   
; Change le char de l'orientation en un caractere plus representatif pour l'affichage dans le tableau et le place sur la pile pour la fonction placeBat
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
         STA     charOriT,s  
         BR      chNbCln 
changChO:LDBYTEA '>',i
         STA     charOriT,s  
; Change le char de la colonne en sa valeur decimal et le place sur la pile pour la fonction placeBat
chNbCln: LDA     iterA,s     ;on retrouve chaque troisieme caractere d'une description de bateau grace a X = A * 5 + 2
         LDX     5,i         ;
         CALL    mult        ;
         STA     resMultA,s  ;
         LDX     resMultA,s  ;
         ADDX    2,i         ;
         LDA     0,i
         LDBYTEA descBat,sxf
         SUBA    'A',i
         STA     nbColnT,s    
; Change le char de la rangee en sa valeur decimal et le place sur la pile pour la fonction placeBat
         LDA     iterA,s     ;on retrouve chaque quatrieme caractere d'une description de bateau grace a X = A * 5 + 3
         LDX     5,i         ;
         CALL    mult        ;
         STA     resMultA,s  ;
         LDX     resMultA,s  ;
         ADDX    3,i         ;
         LDA     0,i
         LDBYTEA descBat,sxf
         SUBA    '1',i
         STA     nbRangeT,s  
         LDA     iterA,s     
         ADDA    1,i         
         STA     iterA,s     ;A++
         CALL    placeBat    ;tous les parametre ont ete place sur la pile, on peut appeller la fonction placeBat
         BR      batPLoop    
finBat:  ADDSP   16,i        ;libere variables locales
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
; IN: SP+14 = int nbCases 
;     SP+16 = char orientation
;     SP+18 = int colonne
;     SP+20 = int rangee
placeBat:CALL    verPBat     ;on verifie d'abord si le bateau peut etre place avec verPBat, la methode utilise les informations deja sur la pile
         SUBSP   4,i         ;reserve les variables locales
         CPA     0,i         ;
         BREQ    finPBat     ;si la methode retourne 0, on ne place rien et quitte placeBat
         LDA     16,s        ;
         CPA     'v',i       ;regarde si on place de maniere horizontale ou verticale
         BREQ    grandVer    ;
         LDA     0,i
         STA     iterA2,s
loopGraH:CPA     14,s        ;for (iterA2 = 0; iterA2 < nbCases; iterA2++){
         BRGE    finPBat     ;
         LDA     20,s        ;
         LDX     NB_COLN,i   ;
         CALL    mult        ;
         ADDA    iterA2,s    ;
         ADDA    18,s        ;
         STA     resPTmp,s   ;    resPTmp = colonne + mult(rangee, NB_COLN) + iterA2
         LDX     resPTmp,s   ;    X = resPTmp
         LDA     16,s        ;
         STBYTEA TABLEAU,x   ;    TABLEAU[X] = char orientation
         LDA     iterA2,s    ;
         ADDA    1,i         ;    iterA2++
         STA     iterA2,s    ;
         BR      loopGraH    ;}
grandVer:LDA     0,i
         STA     iterA2,s
loopGraV:CPA     14,s        ;for (iterA2 = 0; iterA2 < nbCases; iterA2++){
         BRGE    finPBat     ;
         LDA     20,s        ;
         ADDA    iterA2,s    ;
         LDX     NB_COLN,i   ;
         CALL    mult        ;
         ADDA    18,s        ;
         STA     resPTmp,s   ;    resPTmp = colonne + mult(rangee + iterA2, NB_COLN)
         LDX     resPTmp,s   ;    X = resPTmp
         LDA     16,s        ;    
         STBYTEA TABLEAU,x   ;    TABLEAU[X] = char orientation
         LDA     iterA2,s    ;
         ADDA    1,i         ;    iterA2++
         STA     iterA2,s    ;
         BR      loopGraV    ;}
finPBat: RET4                ;libere les variables locales en quittant la methode
iterA2:  .EQUATE 0           ;contient la valeur utilise pour parcourir les boucles
resPTmp: .EQUATE 2           ;utiliser pour sauvegarder des resultats d'operations



; Verifie si un bateau peut etre entre dans le tableau en regardant sa position et s'il ne rentre pas en collision avec un autre
; IN: SP+16 = int nbCases
;     SP+18 = char orientation
;     SP+20 = int colonne
;     SP+22 = int rangee
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
         LDA     20,s        ;
         ADDA    iterX,s     ;
         LDX     22,s        ;
         CALL    verHorsC    ;verHorsC(colonne + iterX, rangee), parametres passes par indexes 
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
VPBVert: LDA     20,s        ;
         LDX     22,s        ;
         ADDX    1,i         ;
         CALL    verHorsC    ;verHorsC(colonne + iterX, rangee), parametres passes par indexes 
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
iterX:   .EQUATE 0           ;utiliser pour l'index de boucle locale
resMX:   .EQUATE 2           ;utiliser pour sauvegarder des resultats d'operations



; Verifie si une position colonne/rangee est a l'interieur du jeu.
; IN: A = position en colonne
;     X = position en rangee
; OUT: 1 par l'accumulateur si la position est a l'interieur du tableau, 0 si non.
verHorsC:SUBSP   8,i
         STA     clnTmp,s
         STX     rangTmp,s
         CPA     0,i         ;
         BRLT    horsC       ;A et X doivent être positifs
         CPX     0,i         ;
         BRLT    horsC       ;
         LDX     NB_COLN,i   ;resTmp2 = mult(rangee, NB_COLN) + colonne
         LDA     rangTmp,s
         CALL    mult        ;
         ADDA    clnTmp,s    ;
         STA     resTmp2,s   ;
         LDA     rangTmp,s   ;On vérifie si resTmp2 < mult(rangee + 1, NB_COLN)
         ADDA    1,i         ;Sinon, on retourne 0 dans l'accumulateur
         CALL    mult        ;
         CPA     resTmp2,s   ;
         BRLE    horsC
         LDA     1,i         ;met 1 dans l'accumulateur si toute les comparaisons ont retournees vrai
         BR      finVHC    
horsC:   LDA     0,i         ;met 0 dans l'accumulateur si une comparaison a echoue.
finVHC:  ADDSP   8,i         ;libere les variables locales
         RET0
clnTmp:  .EQUATE 0           ;contient la position en colonne
rangTmp: .EQUATE 2           ;contient la position en rangee
resTmp1: .EQUATE 4           ;utiliser pour sauvegarder des resultats d'operations
resTmp2: .EQUATE 6           ;utiliser pour sauvegarder des resultats d'operations



; Verifie la description d'un bateau.
; IN: A = addresse de la description du bateau
; OUT: 1 par l'accumulateur si le bateau est conforme, 0 si non.
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
descTmp: .EQUATE 0           ;contient l'addresse
verTmpX: .EQUATE 2           ;contient la valeur d'origine de X



; Sollicite l'utilisateur a entrer les feux a tirer sur les bateaux, jusqu'a la fin du jeu.
feuVolnt:SUBSP   2,i         ;reserve variable locale
         CALL    printTab    ;affiche le tableau
         STRO    MSG_TIR,d
loopFeuV:CALL    batPres     ;while(batPres){
         CPA     0,i         ;
         BREQ    finFVlnt    ;
descFVol:CALL    creeDesc
         STX     descFeu,s   ;    range l'addresse dans descFeu
         CALL    verFeuEn    ;    la methode verFeuEn se sert de l'addresse de descFeu place dans la pile
         CPA     1,i         ;
         BRNE    descFVol    ;    si la verification echoue on sollicite encore
         CALL    cntNbFeu    ;    la methode cntNbFeu se sert de l'addresse de descFeu place dans la pile
         CALL    placeFeu    ;    la methode placeFeu se sert du nombre de feux place dans A et l'addresse de descFeu place dans la pile
         BR      loopFeuV    ;}
finFVlnt:RET2
descFeu: .EQUATE 0           ;contient l'addresse du descripteur de feux



; Place les feux specifies sur le tableau
; IN: SP+12 = l'addresse du descripteur de feux
;     A = nombre de feux a placer
placeFeu:SUBSP   10,i
         STA     nbFeuPF,s
         LDX     0,i
         STX     iterX2,s
loopPF:  CPX     nbFeuPF,s
         BRGE    finPF
         LDA     3,i
         CALL    mult
         STA     resTmpX2,s
         LDX     resTmpX2,s
         LDBYTEA 12,sxf
         SUBA    'A',i
         STA     colnTmp2,s
         LDA     3,i
         LDX     iterX2,s
         CALL    mult
         ADDA    1,i
         STA     resTmpX2,s
         LDX     resTmpX2,s
         LDBYTEA 12,sxf
         SUBA    '1',i
         STA     rangTmp2,s
         LDA     colnTmp2,s
         LDX     rangTmp2,s
         CALL    tirerFeu 
         CALL    printTab
         LDX     iterX2,s
         ADDX    1,i
         STX     iterX2,s
         BR      loopPF
finPF:   ADDSP   10,i
         RET0
nbFeuPF: .EQUATE 0
iterX2:  .EQUATE 2
resTmpX2:.EQUATE 4
colnTmp2:.EQUATE 6
rangTmp2:.EQUATE 8



; Tire un feu dans le tableau en changeant le caractere representat l'eau ou bateaux
; par celui d'un feu rate ou touche. Un bateau touche par un feu cree 4 debris chacun
; similaire a l'effet d'un feu, on utilise donc de la recursion pour creer cet effet
; a ces cases.
; IN: A = la colonne ou on tire le feu
;     X = la rangee ou on tire le feu 
tirerFeu:SUBSP   6,i
         STA     colnTmp3,s
         STX     rangTmp3,s
         CALL    verHorsC
         CPA     1,i
         BRNE    finTF
         LDX     rangTmp3,s
         LDA     NB_COLN,i
         CALL    mult
         ADDA    colnTmp3,s
         STA     posTabT,s
         LDX     posTabT,s
         LDBYTEA TABLEAU,x
         CPA     'v',i
         BREQ    suiteTF
         CPA     '>',i
         BREQ    suiteTF
         CPA     '*',i
         BREQ    finTF
         LDBYTEA 'o',i
         STBYTEA TABLEAU,x
         BR      finTF 
suiteTF: LDBYTEA '*',i
         STBYTEA TABLEAU,x
         LDA     colnTmp3,s
         ADDA    1,i
         LDX     rangTmp3,s
         CALL    tirerFeu
         LDA     colnTmp3,s
         SUBA    1,i
         LDX     rangTmp3,s
         CALL    tirerFeu
         LDA     colnTmp3,s
         LDX     rangTmp3,s
         ADDX    1,i
         CALL    tirerFeu
         LDA     colnTmp3,s
         LDX     rangTmp3,s
         SUBX    1,i
         CALL    tirerFeu
         BR      finTF
finTF:   RET6 
colnTmp3:.EQUATE 0
rangTmp3:.EQUATE 2
posTabT: .EQUATE 4



; Compte le nombre de feux dans le descripteur donne par A.
; IN: SP+4 = l'addresse du descripteur de feux
; OUT: A = nombre de feux dans la description
cntNbFeu:SUBSP   2,i         ;reserve variable locale
         LDX     0,i
         LDA     0,i
         STA     nbFeu,s
loopCNF: LDBYTEA 4,sxf       ;while (descripteurFeux[x] != '\n') {
         CPA     '\n',i      ;
         BREQ    finCNFeu    ;
         CPA     ' ',i       ;    if (descripteurFeux[x] == ' '){
         BREQ    nbFeuInc    ;        nbFeu++
         ADDX    1,i         ;    }
         BR      loopCNF     ;}
nbFeuInc:LDA     nbFeu,s     ;incrementation de nbFeu
         ADDA    1,i         ;
         STA     nbFeu,s     ;
         ADDX    1,i         ;
         BR      loopCNF     ;retourne au debut de while
finCNFeu:LDA     nbFeu,s     ;
         ADDA    1,i         ;return nombre d'espaces + 1
         RET2                ;
nbFeu:   .EQUATE 0           ;contient le nombre de feu du descripteur de feux



; Verifie que les feux entres par l'utilisateur sont conformes a l'enonce.
; C'est a dire qu'il y a un espace entre chaque descripteur de feux et que
; la description d'un feux ait 2 caracteres valides.
; IN: SP+4 = l'addresse du descripteur de feux
; OUT: A = 1 si oui, 0 si non
verFeuEn:SUBSP   2,i         ;reserve variable locale
         LDX     0,i         ;X = 0
loopSepF:LDBYTEA 4,sxf       ;verifie si la colonne est valide
         CPA     'A',i       ;
         BRLT    descFeuF    ;si descTmp[X] < 'A', la colonne est invalide
         CPA     'R',i       ;
         BRGT    descFeuF    ;si descTmp[X] > 'R', la colonne est invalide   
         ADDX    1,i         ;X =+ 1
         LDBYTEA 4,sxf       ;colonne valide, verifie maintenant la rangee
         CPA     '1',i       ;
         BRLT    descFeuF    ;si descTmp[X] < '1', la rangee est invalide
         CPA     '9',i       ;
         BRGT    descFeuF    ;si descTmp[X] > '9', la rangee est invalide
         BR      descFeuV    ;
descFeuF:LDA     0,i         ;un echec de verification met 0 dans l'accumulateur
         STRO    MSG_ETIR,d
         BR      finVFE 
descFeuV:ADDX    1,i         ;X += 1
         LDBYTEA 4,sxf       ;A = X 
         ADDX    1,i         ;X += 1
         CPA     '\n',i      ;si A != '\n' il y a au moins une autre description de feu
         BRNE    loopSepF
         LDA     1,i         ;un succes de verification met 1 dans l'accumulateur
finVFE:  RET2



; Verifie si au moins un bateau est present dans le tableau.
; OUT: A = 1 si oui, 0 si non.
batPres: LDX     0,i
loopBatP:LDA     0,i
         CPX     NB_CASES,i
         BRGE    finBPres
         LDBYTEA TABLEAU,x
         CPA     'v',i
         BREQ    batPresV
         CPA     '>',i
         BREQ    batPresV
         ADDX    1,i
         BR      loopBatP
batPresV:LDA     1,i
finBPres:RET0         



; Lecteur de string, s'arrete lorsqu'on pese sur ENTREE.
; Utilise le tas pour cree le tableau
; OUT: X = le pointeur du tableau
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
desc:    .EQUATE 0           ;contient l'addresse



; Operateur new
; IN: A = contient nombre d'octets
; OUT: X = contient un pointeur vers le tas
new:     LDX     hpPtr,d  ;pointeur retourne 
         ADDA    hpPtr,d  ;
         STA     hpPtr,d  ;prochaine addresse 
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
MSG_TIR: .ASCII  "Feu a volonte!\n(entrer les coups a tirer: colonne[A-R] "
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

; Tas
heap:    .BLOCK  1
         .END
