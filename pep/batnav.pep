; Ce programme fait jouer un jeu de bataille navale. Le jeu est joue par un seul
; joueur. Le joueur commence par placer des navires sur une grille, puis il leur
; tire dessus.
;
; Auteur: Wiliam Chretien,        Code permanent: CHRW15109406
; Auteur: Ricardo Ruy Valle-Mena, Code permanent: VALR29129407
;
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


; Initialise le tableau avec des cases considerees vides.
initTab: LDX     0,i
; loop pour remplir chaque case du tableau avec un '~'
ITLoop:  CPX     NB_CASES,i
         BRGE    ITFin
         LDBYTEA '~',i
         STBYTEA TABLEAU,x
         ADDX    1,i
         BR      ITLoop
ITFin:   RET0



; Affiche le tableau.
printTab:SUBSP   6,i
         STRO    MSG_COLN,d
         LDX     0,i
;Loop pour afficher chaque valeur des rangees
PTLoopRn:CHARO   '\n',i
         ADDX    1,i
         STX     PTRangee,s  ;affiche la position de rangee + 1 (car on commence a 0) et '|'
         SUBX    1,i         ;
         CPX     NB_RANGE,i  ;
         BRGE    PTFin       ;
         DECO    PTRangee,s  ;
         CHARO   '|',i       ;
         LDA     0,i
;Loop pour afficher chaque valeur du tableau par rapport a la rangee et colonne
PTLoopCl:CPA     NB_COLN,i   ;for (A=0; A <= 18; A++) {
         BRGE    finCl       ;
         STA     PTColn,s    ;
         STX     PTRangee,s  ;
         LDA     NB_COLN,i   ;    A = NB_COLN * PTRangee + PTColn
         CALL    mult        ;    
         ADDA    PTColn,s    ;    
         STA     PTTmpM,s    ;
         LDX     PTTmpM,s    ;    X = A
         CHARO   TABLEAU,x   ;    print(TABLEAU[X])
         LDA     PTColn,s    ;    
         LDX     PTRangee,s  ;
         ADDA    1,i         ;    A++
         BR      PTLoopCl    ;}
finCl:   CHARO   '|',i       ;
         ADDX    1,i         ;la rangee a ete imprimer au complet, on incremente X pour passer a la prochaine
         BR      PTLoopRn    ;
PTFin:   ADDSP   6,i         ;libere variables locales
         RET0
PTColn:  .EQUATE 0           ;contient la valeur de la colonne
PTRangee:.EQUATE 2           ;contient la valeur de la rangee
PTTmpM:  .EQUATE 4           ;utilise pour calculer la multiplication




; Verifie que les bateaux entres sont conformes a l'enonce. C'est a dire qu'il y a un espace entre chaque descripteur
; de bateaux et que ce descripteur ait 4 caracteres valides.
verifBat:SUBSP   16,i        ;reserve variables locales
         BR      iniVarVB 
loopVBat:CALL    creeDesc    ;initialise le descripteur de bateaux
         STX     descBat,s   ;range le pointeur du descripteur de bateaux dans X
         LDX     0,i
loopVdes:LDA     descBat,s   ;met le pointeur du descripteur dans A pour appeller verDescB
         CALL    verDescB    ;la methode retourne 0 si une description de bateau est mauvaise, 1 si bonne
         CPA     1,i         ;
         BREQ    batVal      ;
         STRO    MSG_EBAT,d  ;un echec de verification du descripteur de bateaux affiche un msg d'erreur et reinitialise le nombre de bateaux
iniVarVB:LDA     0,i         ;initialise le nombre de bateaux a 0
         STA     nbBateau,s  ;
         BR      loopVBat    ; 
batVal:  LDA     nbBateau,s  ;lorsque description du bateau est valide on incremente le nombre de bateaux
         ADDA    1,i         ;
         STA     nbBateau,s  ;
         ADDX    4,i         ;X += 4
         LDBYTEA descBat,sxf ;A = desc[X]
         ADDX    1,i         ;X += 1
         CPA     '\n',i      ;si A != '\n' il y a au moins une autre description de bateaux
         BRNE    loopVdes    ;
; Loop pour placer les bateaux
         LDA     0,i
         STA     iterA,s
batPLoop:LDA     iterA,s     ;for (A = 0; A < nbBateau; A++) {
         CPA     nbBateau,s  ;
         BREQ    finBat      ;
         LDX     5,i         ;    on retrouve chaque premier caractere d'une description de bateau grace a X = A * 5
         CALL    mult        ;
         STA     resMultA,s  ;
         LDX     resMultA,s  ;    X = A * 5
         LDA     0,i         ;
         LDBYTEA descBat,sxf ;    A = descBat[X]
         CPA     'p',i       ;    if (A == 'p'){
         BREQ    nbCases1    ;        nbCasesT = 1
         CPA     'm',i       ;    } elif (A == 'm') {
         BREQ    nbCases3    ;        nbCasesT = 3
         LDA     5,i         ;    } else {
         STA     nbCasesT,s  ;        nbCasesT = 5
         BR      signOrie    ;    }
nbCases1:LDA     1,i         ;
         STA     nbCasesT,s  ;
         BR      signOrie    ;
nbCases3:LDA     3,i         ;
         STA     nbCasesT,s  ;
signOrie:LDA     iterA,s     ;    maintenant, on retrouve chaque deuxieme caractere d'une description de bateau grace a X = A * 5 + 1 
         LDX     5,i         ;
         CALL    mult        ;
         STA     resMultA,s  ;
         LDX     resMultA,s  ;    
         ADDX    1,i         ;    X = A * 5 + 1
         LDA     0,i         ;
         LDBYTEA descBat,sxf ;    A = descBat[X]
         CPA     'h',i       ;    if (A == 'h') 
         BREQ    changChO    ;        charOriT = '>'
         STA     charOriT,s  ;    charOriT = 'v'
         BR      chNbCln     ;        
changChO:LDBYTEA '>',i       ;    
         STA     charOriT,s  ;
chNbCln: LDA     iterA,s     ;    ensuite, on retrouve chaque troisieme caractere d'une description de bateau grace a X = A * 5 + 2
         LDX     5,i         ;
         CALL    mult        ;
         STA     resMultA,s  ;
         LDX     resMultA,s  ;    
         ADDX    2,i         ;    X = A * 5 + 2
         LDA     0,i         ;
         LDBYTEA descBat,sxf ;    A = descBat[X]
         SUBA    'A',i       ;    
         STA     nbColnT,s   ;    nbColnT = A - 'A'
         LDA     iterA,s     ;    finalement, on retrouve chaque quatrieme caractere d'une description de bateau grace a X = A * 5 + 3
         LDX     5,i         ;
         CALL    mult        ;
         STA     resMultA,s  ;
         LDX     resMultA,s  ;
         ADDX    3,i         ;    X = A * 5 + 3
         LDA     0,i         ;
         LDBYTEA descBat,sxf ;    A = descBat[X]
         SUBA    '1',i       ;
         STA     nbRangeT,s  ;    nbRangeT = A - '1'
         LDA     iterA,s     ;
         ADDA    1,i         ;
         STA     iterA,s     ;    A++
         CALL    placeBat    ;    tous les parametre ont ete place sur la pile, on peut appeller la fonction placeBat
         BR      batPLoop    ;}
finBat:  ADDSP   16,i        ;libere variables locales
         RET0
descBat: .EQUATE 0           ;contient le pointeur de l'objet du descripteur
nbBateau:.EQUATE 2           ;le nombre de bateau valides
resMultA:.EQUATE 4           ;le resultat le la fonction mult
iterA:   .EQUATE 6           ;sauvegarde l'iterateur quand on a besoin de l'accumulateur pour autre chose
nbCasesT:.EQUATE 8           ;nombre cases place en parametre par la pile pour placeBat
charOriT:.EQUATE 10          ;caractere orientation place en parametre par la pile pour placeBat
nbColnT: .EQUATE 12          ;nombre colonnes place en parametre par la pile pour placeBat
nbRangeT:.EQUATE 14          ;nombre rangees place en parametre par la pile pour placeBat



; Place un bateau dans le tableau en changeant le caractere representant l'eau par celui de l'orientation du bateau.
; IN: SP+14 = int nbCases.
;     SP+16 = char orientation.
;     SP+18 = int colonne.
;     SP+20 = int rangee.
placeBat:CALL    verPBat     ;on verifie d'abord si le bateau peut etre place, la methode utilise les informations deja sur la pile
         SUBSP   4,i         ;reserve les variables locales
         CPA     0,i         ;
         BREQ    finPBat     ;si la methode retourne 0, on ne place rien et quitte placeBat
         LDA     16,s        ;A = char orientation
         CPA     'v',i       ;regarde si on place de maniere horizontale ou verticale
         BREQ    grandVer    ;
         LDA     0,i         ;
         STA     iterA2,s    ;
loopGraH:CPA     14,s        ;for (iterA2 = 0; iterA2 < nbCases; iterA2++){
         BRGE    finPBat     ;
         LDA     20,s        ;    A = rangee
         LDX     NB_COLN,i   ;    X = 18
         CALL    mult        ;
         ADDA    iterA2,s    ;
         ADDA    18,s        ;    A = colonne + mult(rangee, NB_COLN) + iterA2
         STA     resPTmp,s   ;    resPTmp = A
         LDX     resPTmp,s   ;    X = resPTmp
         LDA     16,s        ;
         STBYTEA TABLEAU,x   ;    TABLEAU[X] = char orientation
         LDA     iterA2,s    ;
         ADDA    1,i         ;    iterA2++
         STA     iterA2,s    ;
         BR      loopGraH    ;}
grandVer:LDA     0,i         ;
         STA     iterA2,s    ;
loopGraV:CPA     14,s        ;for (iterA2 = 0; iterA2 < nbCases; iterA2++){
         BRGE    finPBat     ;
         LDA     20,s        ;    A = rangee
         ADDA    iterA2,s    ;    A += iterA2
         LDX     NB_COLN,i   ;    X = 18
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
finPBat: RET4                ;libere les variables locales tout en quittant la methode
iterA2:  .EQUATE 0           ;contient la valeur utilise pour parcourir les boucles
resPTmp: .EQUATE 2           ;utiliser pour sauvegarder des resultats d'operations



; Verifie si un bateau peut etre entre dans le tableau en regardant sa position et s'il ne rentre pas en collision avec un autre.
; IN: SP+16 = int nbCases.
;     SP+18 = char orientation.
;     SP+20 = int colonne.
;     SP+22 = int rangee.
; OUT: 1 par l'accumulateur si oui, 0 si non.
verPBat: SUBSP   4,i         ;reserve variables locales
         LDX     0,i         ;
         STX     iterX,s     ;
loopVPB: LDX     iterX,s     ;for (iterX = 0; iterX < nbCases; X++) {
         CPX     16,s        ;
         BRGE    finVerVa    ;
         LDA     18,s        ;    A = char orientation
         CPA     'v',i       ;    if (A == 'V') 
         BREQ    VPBVert     ;        goto VPBVert
         LDA     20,s        ;    A = colonne
         ADDA    iterX,s     ;    A += iterX
         LDX     22,s        ;    X = rangee
         CALL    verHorsC    ;    verHorsC(A, X), parametres passes par indexes 
         CPA     0,i         ;
         BREQ    placBInv    ;    si verHorsC retourne 0 alors placement invalide
         LDA     22,s        ;    A = rangee
         LDX     NB_COLN,i   ;    X = 18
         CALL    mult        ;
         ADDA    20,s        ;
         ADDA    iterX,s     ;    
         STA     resMX,s     ;    resMx = colonne + mult(rangee, NB_COLN) + iterX
         LDX     resMX,s     ;    X = resMx
         LDA     0,i         ;
         LDBYTEA TABLEAU,x   ;    A = TABLEAU[X]
         CPA     '~',i       ;    
         BRNE    placBInv    ;    return A == '~'
         LDX     iterX,s     ;
         ADDX    1,i         ;    
         STX     iterX,s     ;    iterX++
         BR      loopVPB     ;}
VPBVert: LDA     20,s        ;A = colonne
         LDX     22,s        ;X = rangee
         ADDX    1,i         ;X += 1
         CALL    verHorsC    ;verHorsC(A, X), parametres passes par indexes 
         CPA     0,i         ;
         BREQ    placBInv    ;si verHorsC retourne 0 alors placement invalide
         LDA     22,s        ;A = rangee
         LDX     NB_COLN,i   ;X = 18
         CALL    mult        ;
         ADDA    20,s        ;
         STA     resMX,s     ;TABLEAU[colonne + mult(rangee, NB_COLN) + mult(iterX, NB_COLN)] != '~'
         LDA     iterX,s     ;
         CALL    mult        ;
         ADDA    resMX,s     ;
         STA     resMX,s     ;resMx = colonne + mult(rangee, NB_COLN) + mult(iterX, NB_COLN)
         LDX     resMX,s     ;X = resMx
         LDA     0,i         ;
         LDBYTEA TABLEAU,x   ;A = TABLEAU[X]
         CPA     '~',i       ;
         BRNE    placBInv    ;return A == '~'
         LDX     iterX,s     ;
         ADDX    1,i         ;
         STX     iterX,s     ;iterX++
         BR      loopVPB     ;goto loopVPB
placBInv:LDA     0,i         ;placement invalide, retourne 0 par l'accumulateur
         BR      finVerPB    ;
finVerVa:LDA     1,i         ;placement valide, retourne 1 par l'accumulateur
finVerPB:RET4                ;libere les variables locales tout en quittant la methode
iterX:   .EQUATE 0           ;utiliser pour l'index de boucle locale
resMX:   .EQUATE 2           ;utiliser pour sauvegarder des resultats d'operations



; Verifie si une position colonne/rangee est a l'interieur du jeu.
; IN: A = position en colonne.
;     X = position en rangee.
; OUT: 1 par l'accumulateur si oui, 0 si non.
verHorsC:SUBSP   8,i         ;reserve variables locales
         STA     clnTmp,s
         STX     rangTmp,s
         CPA     0,i         ;A et X doivent etre positifs
         BRLT    horsC       ;
         CPX     0,i         ;
         BRLT    horsC       ;
         LDX     NB_COLN,i   ;X = 18
         LDA     rangTmp,s   ;
         CALL    mult        ;
         ADDA    clnTmp,s    ;
         STA     resTmp2,s   ;resTmp2 = mult(rangee, NB_COLN) + colonne
         LDA     rangTmp,s   ;On verifie si resTmp2 < mult(rangee + 1, NB_COLN)
         ADDA    1,i         ;
         CALL    mult        ;
         CPA     resTmp2,s   ;
         BRLE    horsC       ;sinon, on retourne 0 dans l'accumulateur
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
; IN: A = addresse de la description du bateau.
; OUT: 1 par l'accumulateur si le bateau est conforme, 0 si non.
verDescB:SUBSP   4,i         ;reserve les variables locales
         STX     verTmpX,s   ;sauvegarde la valeur d'origine de X dans verTmpX
         STA     descTmp,s   ;range le pointeur dans descTmp
         LDA     0,i
         LDBYTEA descTmp,sxf ;compare la premiere lettre de la description du bateau soit la grandeur 
         CPA     'p',i       ;
         BREQ    GValide     ;
         CPA     'm',i       ;
         BREQ    GValide     ;
         CPA     'g',i       ;
         BREQ    GValide     ;
         BR      descBatF    ;si aucun matche, description du bateau invalide
GValide: ADDX    1,i         ;si la grandeur est valide, on verifie maintenant la deuxieme lettre soit l'orientation
         LDBYTEA descTmp,sxf ;
         CPA     'h',i       ;
         BREQ    OValide     ;
         CPA     'v',i       ;
         BREQ    OValide     ;
         BR      descBatF    ;si aucun matche, description du bateau invalide
OValide: ADDX    1,i         ;si orientation valide, on verifie maintenant la troisieme lettre soit la colonne
         LDBYTEA descTmp,sxf ;
         CPA     'A',i       ;
         BRLT    descBatF    ;si descTmp[X] < 'A', la colonne est invalide
         CPA     'R',i       ;
         BRGT    descBatF    ;si descTmp[X] > 'R', la colonne est invalide
         ADDX    1,i         ;si colonne valide, on verifie maintenant la quatrieme lettre soit la rangee
         LDBYTEA descTmp,sxf ;
         CPA     '1',i       ;
         BRLT    descBatF    ;si descTmp[X] < '1', la rangee est invalide
         CPA     '9',i       ;
         BRGT    descBatF    ;si descTmp[X] > '9', la rangee est invalide
         BR      descBatV    ;tout les tests ont passes, description du bateau est valide
descBatF:LDA     0,i         ;un echec de verification met 0 dans l'accumulateur
         BR      finVerDB    ;
descBatV:LDA     1,i         ;un succes de verification met 1 dans l'accumulateur
finVerDB:LDX     verTmpX,s   ;restore la valeur d'origine a X
         ADDSP   4,i         ;libere les variables locales
         RET0
descTmp: .EQUATE 0           ;contient l'addresse du descripteur de bateaux
verTmpX: .EQUATE 2           ;contient la valeur d'origine de X



; Sollicite l'utilisateur a entrer les feux a tirer sur les bateaux, jusqu'a la fin du jeu.
feuVolnt:SUBSP   2,i         ;reserve variable locale
         CALL    printTab    ;affiche le tableau
         STRO    MSG_TIR,d
loopFeuV:CALL    batPres     ;while(batPres){
         CPA     0,i         ;
         BREQ    finFVlnt    ;
descFVol:CALL    creeDesc    ;
         STX     descFeu,s   ;    range l'addresse dans descFeu
         CALL    verFeuEn    ;    la methode verFeuEn se sert de l'addresse de descFeu place dans la pile
         CPA     1,i         ;
         BRNE    descFVol    ;    si la verification echoue on cree un nouveau descripteur
         CALL    cntNbFeu    ;    la methode cntNbFeu se sert de l'addresse de descFeu place dans la pile
         CALL    placeFeu    ;    la methode placeFeu se sert du nombre de feux place dans A par cntNbFeu et l'addresse de descFeu deja dans la pile
         BR      loopFeuV    ;}
finFVlnt:RET2
descFeu: .EQUATE 0           ;contient l'addresse du descripteur de feux



; Place les feux specifies sur le tableau.
; IN: A = nombre de feux a placer.
;     SP+12 = l'addresse du descripteur de feux.
placeFeu:SUBSP   10,i        ;reserve variables locales
         STA     nbFeuPF,s   ;nbFeuPF = nombre de feux a placer
         LDX     0,i         ;
         STX     iterX2,s    ;
loopPF:  CPX     nbFeuPF,s   ;for (iterX2 = 0; iterX2 < nbFeuPF; iterX2++) {
         BRGE    finPF       ;
         LDA     3,i         ;
         CALL    mult        ;
         STA     resTmpX2,s  ;    resTmpX2 = 3 * iterX2
         LDX     resTmpX2,s  ;    X = resTmpX2
         LDBYTEA 12,sxf      ;    A = descripteurFeux[X]
         SUBA    'A',i       ;
         STA     colnTmp2,s  ;    colnTmp2 = A - 'A'
         LDA     3,i         ;
         LDX     iterX2,s    ;
         CALL    mult        ;
         ADDA    1,i         ;
         STA     resTmpX2,s  ;    resTmpX2 = 3 * iterX2 + 1
         LDX     resTmpX2,s  ;    X = resTmpX2
         LDBYTEA 12,sxf      ;    A = descripteurFeux[X]
         SUBA    '1',i       ;
         STA     rangTmp2,s  ;    rangTmp2 = A - '1'
         LDA     colnTmp2,s  ;    
         LDX     rangTmp2,s  ;    
         CALL    tirerFeu    ;    tirerFeu(A, X), parametres passes par indexes
         CALL    printTab    ;    affiche le tableau
         LDX     iterX2,s    ;
         ADDX    1,i         ;
         STX     iterX2,s    ;    iterX2++
         BR      loopPF      ;}
finPF:   ADDSP   10,i        ;libere les variables locales
         RET0
nbFeuPF: .EQUATE 0           ;contient le nombre de feux a places
iterX2:  .EQUATE 2           ;contient la valeur d'iteration de la boucle
resTmpX2:.EQUATE 4           ;utiliser pour contenir le resultat d'operations
colnTmp2:.EQUATE 6           ;contient la valeur de la colonne
rangTmp2:.EQUATE 8           ;contient la valeur de la rangee



; Tire un feu dans le tableau en changeant le caractere representat l'eau ou bateaux
; par celui d'un feu rate ou touche. Un bateau touche par un feu cree 4 debris chacun
; similaire a l'effet d'un feu, on utilise donc de la recursion pour creer cet effet
; a ces cases.
; IN: A = la colonne ou on tire le feu.
;     X = la rangee ou on tire le feu.
tirerFeu:SUBSP   6,i         ;reserve les variables locales
         STA     colnTmp3,s  ;colnTmp3 = colonne
         STX     rangTmp3,s  ;rangTmp3 = rang
         CALL    verHorsC    ;verHorsC(A, X), parametres passes par indexes
         CPA     1,i         ;
         BRNE    finTF       ;si la position est hors champs on ne tire pas le feu
         LDX     rangTmp3,s  ;
         LDA     NB_COLN,i   ;
         CALL    mult        ;
         ADDA    colnTmp3,s  ;
         STA     posTabT,s   ;posTabT = rangTmp3 * NB_COLN + colnTmp3
         LDX     posTabT,s   ;X = posTabT
         LDBYTEA TABLEAU,x   ;A = TABLEAU[X]
         CPA     'v',i       ;verifie s'il y a un bateau
         BREQ    suiteTF     ;
         CPA     '>',i       ;
         BREQ    suiteTF     ;
         CPA     '*',i       ;s'il y a deja un bateau touche on quitte
         BREQ    finTF       ;
         LDBYTEA 'o',i       ;
         STBYTEA TABLEAU,x   ;sinon TABLEAU[X] = 'o' avant de quitter
         BR      finTF       ;
suiteTF: LDBYTEA '*',i       ;s'il y a un bateau
         STBYTEA TABLEAU,x   ;TABLEAU[X] = '*'
         LDA     colnTmp3,s  ;
         ADDA    1,i         ;
         LDX     rangTmp3,s  ;
         CALL    tirerFeu    ;tirerFeu(colnTmp3 + 1, rangTmp3), parametres passes par indexes
         LDA     colnTmp3,s  ;
         SUBA    1,i         ;
         LDX     rangTmp3,s  ;
         CALL    tirerFeu    ;tirerFeu(colnTmp3 - 1, rangTmp3), parametres passes par indexes
         LDA     colnTmp3,s  ;
         LDX     rangTmp3,s  ;
         ADDX    1,i         ;
         CALL    tirerFeu    ;tirerFeu(colnTmp3, rangTmp3 + 1), parametres passes par indexes
         LDA     colnTmp3,s  ;
         LDX     rangTmp3,s  ;
         SUBX    1,i         ;
         CALL    tirerFeu    ;tirerFeu(colnTmp3, rangTmp3 - 1), parametres passes par indexes
finTF:   RET6                ;libere les variables locales tout en quittant
colnTmp3:.EQUATE 0           ;contient la position en colonne
rangTmp3:.EQUATE 2           ;contient la position en rangee
posTabT: .EQUATE 4           ;contient la position exacte pour le tableau



; Compte le nombre de feux dans le descripteur donne par l'accumulateur.
; IN: SP+4 = l'addresse du descripteur de feux.
; OUT: A = nombre de feux dans la description.
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
         BR      loopCNF     ;goto loopCNF
finCNFeu:LDA     nbFeu,s     ;
         ADDA    1,i         ;return nombre d'espaces + 1 par l'accumulateur
         RET2                ;
nbFeu:   .EQUATE 0           ;contient le nombre de feu du descripteur de feux



; Verifie que les feux entres par l'utilisateur sont conformes a l'enonce.
; C'est a dire qu'il y a un espace entre chaque descripteur de feux et que
; la description d'un feux ait 2 caracteres valides.
; IN: SP+2 = l'addresse du descripteur de feux.
; OUT: A = 1 si oui, 0 si non.
verFeuEn:LDX     0,i         ;X = 0
loopSepF:LDBYTEA 2,sxf       ;A = descripteur de feux [X]
         CPA     'A',i       ;
         BRLT    descFeuF    ;si descTmp[X] < 'A', la colonne est invalide
         CPA     'R',i       ;
         BRGT    descFeuF    ;si descTmp[X] > 'R', la colonne est invalide   
         ADDX    1,i         ;X =+ 1
         LDBYTEA 2,sxf       ;A = descripteur de feux [X]
         CPA     '1',i       ;
         BRLT    descFeuF    ;si descTmp[X] < '1', la rangee est invalide
         CPA     '9',i       ;
         BRGT    descFeuF    ;si descTmp[X] > '9', la rangee est invalide
         BR      descFeuV    ;
descFeuF:LDA     0,i         ;un echec de verification met 0 dans l'accumulateur, affiche un message d'erreur et quitte la methode
         STRO    MSG_ETIR,d  ;
         BR      finVFE      ;
descFeuV:ADDX    1,i         ;X += 1
         LDBYTEA 2,sxf       ;A = descripteur de feux [X] 
         ADDX    1,i         ;X += 1
         CPA     '\n',i      ;si A != '\n' il y a au moins une autre description de feu
         BRNE    loopSepF    ;
         LDA     1,i         ;un succes de verification met 1 dans l'accumulateur et quitte
finVFE:  RET0                ;



; Verifie si au moins un bateau est present dans le tableau.
; OUT: A = 1 si oui, 0 si non.
batPres: LDX     0,i
loopBatP:LDA     0,i
         CPX     NB_CASES,i  ;for (X = 0, X < NB_CASES; X++){
         BRGE    finBPres    ;
         LDBYTEA TABLEAU,x   ;    A = TABLEAU[X]
         CPA     'v',i       ;    if (A == 'v' || A == '>'){
         BREQ    batPresV    ;        
         CPA     '>',i       ;        goto batPresV
         BREQ    batPresV    ;    }
         ADDX    1,i         ;
         BR      loopBatP    ;}
batPresV:LDA     1,i         ;au moins un bateau present met 1 dans l'accumulateur et quitte
finBPres:RET0                ;



; Lecteur de string, s'arrete lorsqu'on pese sur ENTREE.
; Utilise le tas pour cree le tableau.
; OUT: X = le pointeur du tableau.
creeDesc:SUBSP   2,i         ;reserve variable locale
         LDA     STR_LEN,i   ;passe le nombre d'octets qu'aura le tableau a new
         CALL    new         ;
         STX     desc,s      ;range le pointeur retourne par new
         LDX     0,i         ;
         LDA     0,i         ;
loopDesc:CPX     STR_LEN,i   ;for (X = 0; X < STR_LEN; X += 2)
         BRGE    descFin     ;
         CHARI   desc,sxf    ;    desc[X] = CHARI
         LDBYTEA desc,sxf    ;    A = desc[X]
         ADDX    1,i         ;    X++
         CPA     '\n',i      ;    if (A != '\n')
         BRNE    loopDesc    ;        goto loopDesc
descFin: LDX     desc,s      ;retourne le pointeur du tableau par X
         ADDSP   2,i         ;libere la variable locale et quitte
         RET0                ;
desc:    .EQUATE 0           ;contient l'addresse



; Operateur new.
; IN: A = contient nombre d'octets.
; OUT: X = contient un pointeur vers le tas.
new:     LDX     hpPtr,d     ;pointeur retourne 
         ADDA    hpPtr,d     ;
         STA     hpPtr,d     ;prochaine addresse 
         RET0
hpPtr:   .ADDRSS heap        ;contient l'addresse de heap



; Multiplie deux valeurs donnees par l'index et l'accumulateur.
; IN: A = operand 1.
;     X = operand 2.
; OUT: A = le resultat.
mult:    SUBSP   4,i         ;reserve variables locales
         STX     multTmpX,s  ;sauvegarde X et A
         STA     multTmpA,s  ;
         CPX     0,i         ;verifie si un operand est 0, si oui on retourne immediatement un 0
         BREQ    multi0      ;
         CPA     0,i         ;
         BREQ    multi0      ;
         LDX     1,i         ;
multLoop:CPX     multTmpX,s  ;for (X = 1; X < multTmpX; X++){
         BRGE    multFin     ;
         ADDA    multTmpA,s  ;    A += multTmpA
         ADDX    1,i         ;    X++
         BR      multLoop    ;}
multi0:  LDA     0,i         ;met 0 dans l'accumulateur lors d'une multiplication par 0
multFin: LDX     multTmpX,s  ;restore la valeur d'origine de X
         ADDSP   4,i         ;libere vairables locales et quitte.
         RET0                ;
multTmpX:.EQUATE 0           ;contient la valeur original de X
multTmpA:.EQUATE 2           ;contient le resultat



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
