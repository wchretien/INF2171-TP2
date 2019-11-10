; Ce programme fait jouer un jeu de bataille navale. Le jeu est joué par un seul
; joueur. Le joueur commence par placer des navires sur une grille, puis il leur
; tire dessus.
;
; Auteur: Wiliam Chretien,        Code permanent: CHRW15109406
; Auteur: Ricardo Ruy Valle-Mena, Code permanent: VALR29129407
mainLoop:call    initTab
         stro    MSG_BIEN,d
         call    printTab
         stro    MSG_ENTR,d
         call    verifBat
         call    feuVolnt
         stro    MSG_FIN,d
         call    stri
         cpa     '\n',i
         breq    mainLoop
         stop

; fonction qui initialise le tableau
initTab: ldx     0,i
; loop de fonction initTab (IT)
ITLoop:  cpx     NB_CASES,i
         brge    ITFin
         ldbytea '~',i
         stbytea TABLEAU,x
         addx    1,i
         br      ITLoop
; fin de fonction initTab (IT)
ITFin:   ret0

printTab:stro    MSG_COLN,d
         ldx     0,i
; loop rangées (Rn) dans fonction printTab (PT)
PTLoopRn:charo   '\n',i
         addx    1,i
         stx     PTRangee,d
         cpx     NB_RANGE,i
         brgt    PTFin
         deco    PTRangee,d
         charo   '|',i
         lda     0,i
; loop colonnes (Cl) dans fonction printTab (PT)
PTLoopCl:adda    1,i
         cpa     NB_COLN,i
         brgt    PTLoopRn
         sta     PTTmpA,d
         call    mult
         charo   TABLEAU,x
         lda     PTTmpA,d
         br      PTLoopCl
; fin de fonction printTab (PT)
PTFin:   ret0
; utilisé pour sauvegarder et restaurer l'indexe
PTTmpA:  .word   0
; garde la valeur de la rangée à laquelle on est, pour l'imprimer
PTRangee:.word   0

; Multiplie deux valeurs données dans l'indexe et l'accumulateur
; Le résultat sera placé dans l'accumulateur .
mult:    stx     multTmpX,d
         sta     multTmpA,d
         ldx     1,i
multLoop:cpx     multTmpX,d
         brge    multFin
         adda    multTmpA,d
         addx    1,i
         br      multLoop
multFin: ldx     multTmpX,d
         ret0
resultat:.word   0
multTmpX:.word   0
multTmpA:.word   0

; Variables globales représentant les messages qui peuvent être affichés
MSG_BIEN:.ascii  "Bienvenue au jeu de bataille navale!\n\n\x00"
MSG_ENTR:.ascii  "Entrer la description et la position des bateaux\n"
         .ascii  "selon le format suivant, separes par des espaces:\n"
         .ascii  "taill[p/m/g] orientation[h/v] colonne [A-R] rangee[1-9]\n"
         .ascii  "ex: ghC4 mvM2 phK9\n\x00"
MSG_TIR: .ascii  "Feu a volonote!\n(entrer les coups a tirer: colonne[A-R] "
         .ascii  "rangee [1-9])\nex: A3 I5 M3\n\x00"
; le message d'erreur de placement de tir
MSG_ETIR:.ascii  "Erreur! Mauvais placement de tirs, veuillez recommencer.\n\x00"
MSG_FIN: .ascii  "Vous avez aneanti la flotte!\nAppuyer sur <Enter> pour jouer "
         .ascii  "a nouveau ou\nn'importe quelle autre saisie pour quitter.\n\x00"
MSG_BYE: .ascii  "Au revoir!\x00"
; le message d'erreur de placement de bateau
MSG_EBAT:.ascii  "Erreur! Mauvais placement de bateaux, veuillez recommencer.\n\x00"
; les noms de colonnes pour quand on imprime le tableau
MSG_COLN:.ascii  "  ABCDEFGHIJKLMNOPQR\x00"
NB_RANGE:.equate 9
NB_COLN: .equate 18
NB_CASES:.equate 162
; taille maximale des strings
STR_LEN: .equate 900
TABLEAU: .block  162
         .end