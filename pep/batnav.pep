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
MSG_COLN:.ascii  "  ABCDEFGHIJKLMNOOPQR\n\x00"
NB_COLN: .equate 18
NB_CASES:.equate 162
; taille maximale des strings
STR_LEN: .equate 900
TABLEAU: .block  NB_CASES