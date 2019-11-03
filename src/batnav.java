public class batnav {

    private static final String MSG_BIENV = "Bienvenue au jeu de bataille navale!\n\n";
    private static final String MSG_ENTRER = "Entrer la description et la position des bateaux\nselon le format suivant," +
            " separes par des espaces:\ntaille[p/m/g] orientation[h/v] colonne[A-R] rangee[1-9]\nex: ghC4 mvM2 phK9\n";
    private static final String MSG_TIRER = "Feu a volonte!\n(entrer les coups a tirer: colonne [A-R] rangee [1-9])" +
            "\nex: A3 I5 M3\n";
    private static final String MSG_ERR_TIRER = "Erreur! Mauvais placement de tires, veuillez recommencer.\n";
    private static final String MSG_FIN = "Vous avez aneanti la flotte!\nAppuyer sur <Enter> pour jouer a nouveau ou" +
            "\nn'importe quelle autre saisie pour quitter.\n";
    private static final String MSG_REVOIR = "Au revoir!";
    private static final String MSG_ERR_PLACE = "Erreur! Mauvais placement de bateaux, veuillez recommencer.\n";
    private static final String POS_COL = "  ABCDEFGHIJKLMNOPQR\n";
    private static final char [] TABLEAU_CASES = new char [162];

    /**
     *
     */
    private static void initJeu() {
        for (int i = 0; i < TABLEAU_CASES.length; i++) {
            TABLEAU_CASES[i] = '~';
        }
        Pep8.stro(MSG_BIENV);
        printTableau();
        Pep8.stro(MSG_ENTRER);
        verifierBateauxEntres();
    }

    /**
     *
     */
    private static void printTableau() {
        Pep8.stro(POS_COL);
        for (int i = 0; i < 9; i++) {
            Pep8.stro((i + 1) + "|");
            for (int j = 0; j < 18; j++) {
                Pep8.charo(TABLEAU_CASES[j + i * 18]);
            }
            Pep8.stro("|\n");
        }
    }

    /**
     *
     */
    private static void verifierBateauxEntres(){
        char [] descripteurBateaux = creerDescripteur();
        char separateurBateaux;
        int nbBateaux = 0;
        int nbEspaces = verifierNbEspaces(descripteurBateaux);
        int i = 0;

        do {
            if ((nbBateaux == 0 || nbEspaces >= nbBateaux) &&
                    (verifierGrandeur(descripteurBateaux[i]) &&
                    verifierOrientation(descripteurBateaux[i + 1]) &&
                    verifierColonne(descripteurBateaux[i + 2]) &&
                    verifierRangee(descripteurBateaux[i + 3]))){
                nbBateaux++;
                separateurBateaux = descripteurBateaux[i + 4];
                i += 5;
            } else {
                Pep8.stro(MSG_ERR_PLACE);
                descripteurBateaux = creerDescripteur();
                nbEspaces = verifierNbEspaces(descripteurBateaux);
                nbBateaux = 0;
                separateurBateaux = 0;
                i = 0;
            }
        } while (separateurBateaux != '\n');
        retrouverBateau(descripteurBateaux, nbBateaux);
    }

    /**
     *
     * @param descripteurBateaux
     * @param nbBateaux
     */
    private static void retrouverBateau (char [] descripteurBateaux, int nbBateaux) {
        for (int j = 0; j < nbBateaux; j++){
            placerBateaux(changerNbGrand(descripteurBateaux[j * 5]),
                    changerCharOrien(descripteurBateaux[j * 5 + 1]),
                    changerNbColonne(descripteurBateaux[j * 5 + 2]),
                    changerNbRang(descripteurBateaux[j * 5 + 3]));
        }
        solFeux();
    }

    /**
     *
     */
    private static void solFeux () {
        printTableau();
        Pep8.stro(MSG_TIRER);
        while (verifierBateauPresent()) {
            verifierFeuxEntres();
        }
        solPartie();
    }

    /**
     *
     * @param descripteurBateaux
     * @return
     */
    private static int verifierNbEspaces(char[] descripteurBateaux) {
        int nbEspaces = 0;
        int i = 0;

        while (descripteurBateaux[i] != '\n') {
            if (descripteurBateaux[i] == ' ') {
                nbEspaces++;
            }
            i++;
        }
        return nbEspaces;
    }

    /**
     *
     * @return
     */
    private static char[] creerDescripteur(){
        char[] descripteur = new char[900];
        int i = 0;

        do {
            descripteur[i] = Pep8.chari();
            i++;
        } while (descripteur[i - 1] != '\n');
        return descripteur;
    }

    /**
     *
     * @param grandeur
     * @return
     */
    private static boolean verifierGrandeur(char grandeur) {
        return grandeur == 'p' || grandeur == 'm' || grandeur == 'g';
    }

    /**
     *
     * @param orientation
     * @return
     */
    private static boolean verifierOrientation(char orientation) {
        return orientation == 'h' || orientation == 'v';
    }

    /**
     *
     * @param colonne
     * @return
     */
    private static boolean verifierColonne(char colonne) {
        return colonne >= 'A' && colonne <= 'R';
    }

    /**
     *
     * @param rangee
     * @return
     */
    private static boolean verifierRangee(char rangee) {
        return rangee >= '1' && rangee <= '9';
    }

    /**
     *
     * @param colonne
     * @return
     */
    private static int changerNbColonne(char colonne) {
        return colonne - 'A';
    }

    /**
     *
     * @param rangee
     * @return
     */
    private static int changerNbRang(char rangee) {
        return rangee - '1';
    }

    /**
     *
     * @param grandeur
     * @return
     */
    private static int changerNbGrand(char grandeur) {
        int nbCases;
        switch (grandeur) {
            case 'p': nbCases =1;
                break;
            case 'm': nbCases = 3;
                break;
            default: nbCases = 5;
                break;
        }
        return nbCases;
    }

    /**
     *
     * @param orientation
     * @return
     */
    private static char changerCharOrien(char orientation) {
        char orientationAffichage = 'v';
        if (orientation == 'h') {
            orientationAffichage = '>';
        }
        return  orientationAffichage;
    }

    /**
     *
     * @param grandeur
     * @param orientation
     * @param colonne
     * @param rangee
     * @return
     */
    private static boolean verifierPlacement(int grandeur, char orientation,
                                             int colonne, int rangee) {
        boolean placementValide = true;
        for (int i = 0; i < grandeur; i++) {
            if (orientation == '>') {
                if (!verifierHorsChamps(colonne + i, rangee) ||
                        (TABLEAU_CASES[colonne + rangee * 18 + i] != '~')) {
                    placementValide = false;
                }
            } else if (!verifierHorsChamps(colonne, rangee + i) ||
                    (TABLEAU_CASES[colonne + rangee * 18 + i * 18] != '~')) {
                placementValide = false;
            }
        }
        return placementValide;
    }

    /**
     *
     * @param grandeur
     * @param orientation
     * @param colonne
     * @param rangee
     */
    private static void placerBateaux(int grandeur, char orientation, int colonne, int rangee) {
        if (verifierPlacement(grandeur, orientation, colonne, rangee)) {
            if (orientation == '>') {
                for (int i = 0; i < grandeur; i++) {
                    TABLEAU_CASES[colonne + rangee * 18 + i] = orientation;
                }
            } else {
                for (int i = 0; i < grandeur; i++) {
                    TABLEAU_CASES[colonne + rangee * 18 + i * 18] = orientation;
                }
            }
        }
    }

    /**
     *
     * @param colonne
     * @param rangee
     * @return
     */
    private static boolean verifierHorsChamps(int colonne, int rangee) {
        return (colonne + rangee * 18 < (rangee + 1) * 18)
                && (colonne + rangee * 18 >= 18 + (rangee - 1) * 18)
                && (colonne + rangee * 18 < 162)
                && (colonne + rangee * 18 >= 0);
    }

    /**
     *
     */
    private static void verifierFeuxEntres() {
        char[] descripteurFeux = creerDescripteur();
        char separateurFeux;
        int nbFeux = 0;
        int nbEspaces = verifierNbEspaces(descripteurFeux);
        int i = 0;

        do {
            if ((nbFeux == 0 || nbEspaces >= nbFeux)
                    && verifierColonne(descripteurFeux[i])
                    && verifierRangee(descripteurFeux[i + 1])) {
                nbFeux++;
                separateurFeux = descripteurFeux[i + 2];
                i += 3;
            } else {
                Pep8.stro(MSG_ERR_TIRER);
                descripteurFeux = creerDescripteur();
                nbEspaces = verifierNbEspaces(descripteurFeux);
                separateurFeux = 0;
                nbFeux = 0;
                i = 0;
            }
        } while (separateurFeux != '\n');
        retrouverFeu(descripteurFeux, nbFeux);
    }

    /**
     *
     * @param descripteurFeux
     * @param nbFeux
     */
    private static void retrouverFeu(char [] descripteurFeux, int nbFeux) {
        for (int i = 0; i < nbFeux; i++) {
            placerFeu(changerNbColonne(descripteurFeux[i * 3]), changerNbRang(descripteurFeux[i * 3 + 1]));
            printTableau();
        }
    }

    /**
     *
     * @param colonne
     * @param rangee
     */
    private static void placerFeu(int colonne, int rangee) {
        if (verifierHorsChamps(colonne, rangee)){
            if (verifierBateauPresent(colonne, rangee)){
                TABLEAU_CASES[colonne + rangee * 18] = '*';
                placerFeu(colonne + 1, rangee);
                placerFeu(colonne - 1, rangee);
                placerFeu(colonne, rangee + 1);
                placerFeu(colonne, rangee - 1);
            } else if (TABLEAU_CASES[colonne + rangee * 18] != '*'){
                TABLEAU_CASES[colonne + rangee * 18] = 'o';
            }
        }
    }

    /**
     *
     * @return
     */
    private static boolean verifierBateauPresent() {
        int i = 0;
        boolean bateauxPresent = false;
        while (i < TABLEAU_CASES.length && !bateauxPresent) {
            if (TABLEAU_CASES[i] == 'v' || TABLEAU_CASES[i] == '>') {
                bateauxPresent = true;
            }
            i++;
        }
        return bateauxPresent;
    }

    /**
     *
     * @param colonne
     * @param rangee
     * @return
     */
    private static boolean verifierBateauPresent(int colonne, int rangee) {
        return TABLEAU_CASES[colonne + rangee * 18] == 'v' || TABLEAU_CASES[colonne + rangee * 18] == '>';
    }

    /**
     *
     */
    private static void solPartie() {
        char [] descripteurFin;
        Pep8.stro(MSG_FIN);
        descripteurFin = creerDescripteur();
        if (descripteurFin[0] == '\n') {
            initJeu();
        } else {
            Pep8.stro(MSG_REVOIR);
        }
    }


    public static void main (String [] args) {
        initJeu();
    }
}
