public class batnav {

    private static final String MSG_BIENV = "Bienvenue au jeu de bataille navale!\n\n";
    private static final String MSG_ENTRER = "Entrer la description et la position des bateaux\nselon le format suivant," +
            " separes par des espaces:\ntaille[p/m/g] orientation[h/v] colonne[A-R] rangee[1-9]\nex: ghC4 mvM2 phK9\n";
    private static final String MSG_TIRER = "Feu a volonte!\n(entrer les coups a tirer: colonne [A-R] rangee [1-9])" +
            "\nex: A3 I5 M3\n";
    private static final String MSG_ERR_TIRER = "Erreur! Mauvais placement de tires, veuillez recommencer.\n";
    private static final String MSG_FIN = "Vous avez aneanti la flotte!\nAppuyer sur <Enter> pour jouer a nouveau ou" +
            "n'importe quelle autre saisie pour quitter\n";
    private static final String MSG_REVOIR = "Au revoir!";
    private static final String MSG_ERR_PLACE = "Erreur! Mauvais placement de bateaux, veuillez recommencer.\n";
    private static final String POS_COL = "  ABCDEFGHIJKLMNOPQR\n";
    private static final char [] TABLEAU_CASES = new char [162];

    private static void initJeu() {
        for (int i = 0; i < TABLEAU_CASES.length; i++) {
            TABLEAU_CASES[i] = '~';
        }
        Pep8.stro(MSG_BIENV);
        printTableau();
        Pep8.stro(MSG_ENTRER);
        verifPlacement();
    }

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

    private static void verifPlacement(){
        char [] descripteurBateaux = entreesPlacements();
        char separateurBateaux;
        int nbBateauxEntre = 0;
        int nbEspaces = verifNbEspaces(descripteurBateaux);
        int i = 0;

        do {
            if ((nbBateauxEntre == 0 || nbEspaces == nbBateauxEntre) &&
                    (verifGrandeur(descripteurBateaux[i]) &&
                    verifOrientation(descripteurBateaux[i + 1]) &&
                    verifColonne(descripteurBateaux[i + 2]) &&
                    verifRangee(descripteurBateaux[i + 3]))){
                nbBateauxEntre++;
                separateurBateaux = descripteurBateaux[i + 4];
                i += 5;
            } else {
                Pep8.stro(MSG_ERR_PLACE);
                descripteurBateaux = entreesPlacements();
                nbEspaces = verifNbEspaces(descripteurBateaux);
                nbBateauxEntre = 0;
                separateurBateaux = 0;
                i = 0;
            }
        } while (separateurBateaux != '\n');
        for (int j = 0; j < nbBateauxEntre; j++){
            placementBateau(grandeurEnNb(descripteurBateaux[j * 4]),
                descripteurBateaux[j * 4 + 1],
                colonneEnNb(descripteurBateaux[j * 4 + 2]),
                rangeeEnNb(descripteurBateaux[j * 4 + 3]));
        }
        printTableau();
        Pep8.stro(MSG_TIRER);
        verifFeux(nbBateauxEntre);
    }

    private static int verifNbEspaces(char[] descripteurBateaux) {
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

    private static char[] entreesPlacements(){
        char[] descripteur = new char[900];
        int i = 0;

        do {
            descripteur[i] = Pep8.chari();
            i++;
        } while (descripteur[i - 1] != '\n');
        return descripteur;
    }

    private static boolean verifGrandeur(char grandeur) {
        return grandeur == 'p' || grandeur == 'm' || grandeur == 'g';
    }

    private static boolean verifOrientation(char orientation) {
        return orientation == 'h' || orientation == 'v';
    }

    private static boolean verifColonne(char colonne) {
        return colonne >= 'A' && colonne <= 'R';
    }

    private static boolean verifRangee(char rangee) {
        return rangee >= '1' && rangee <= '9';
    }

    private static int colonneEnNb(char colonne) {
        return colonne - 'A';
    }

    private static int rangeeEnNb(char rangee) {
        return rangee - '1';
    }

    private static int grandeurEnNb(char grandeur) {
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

    private static void placementBateau(int grandeur, char orientation,
            int colonne, int rangee) {
        char orientationChar = 'v';
        if (orientation == 'h') {
            orientationChar = '>';
        }
        for (int i = 0; i < grandeur; i++) {
            if (orientation == 'h') {
                if (verifHorsChampsH(i, colonne, rangee) &&
                        (TABLEAU_CASES[colonne + rangee * 18 + i] == '~')) {
                    TABLEAU_CASES[colonne + rangee * 18 + i] = orientationChar;
                }
            } else if (verifHorsChampsV(i, colonne, rangee) &&
                    (TABLEAU_CASES[colonne + rangee * 18 + i * 18] == '~')) {
                TABLEAU_CASES[colonne + rangee * 18 + i * 18] = orientationChar;
            }
        }
    }

    private static boolean verifHorsChampsH(int i, int colonne, int rangee) {
        return colonne + rangee * 18 + i < (rangee + 1) * 18;
    }

    private static boolean verifHorsChampsV(int i, int colonne, int rangee) {
        return colonne + rangee * 18 + i * 18 < 162;
    }

    private static void verifFeux(int nbBateauxEntre) {
        char[] descripteurFeux = entreesPlacements();
        char separateurFeux;
        int nbFeuxEntre = 0;
        int nbEspaces = verifNbEspaces(descripteurFeux);
        int i = 0;

        do {
            if ((nbFeuxEntre == 0 || nbEspaces == nbFeuxEntre) &&
                    verifCoups(descripteurFeux[i], descripteurFeux[i + 1])) {
                nbFeuxEntre++;
                separateurFeux = descripteurFeux[i + 2];
                i += 3;
            } else {
                Pep8.stro(MSG_ERR_TIRER);
                descripteurFeux = entreesPlacements();
                nbEspaces = verifNbEspaces(descripteurFeux);
                separateurFeux = 0;
                nbFeuxEntre = 0;
                i = 0;
            }
        } while (separateurFeux != '\n');
        for (int j = 0; j < nbBateauxEntre; j++) {
            feuAVolonte(descripteurFeux[j * 2], descripteurFeux[j * 2 + 1]);
        }
    }

    private static boolean verifCoups(char colonne, char rangee) {
        return verifColonne(colonne) && verifRangee(rangee);
    }

    //TODO, utliser recursivite et methodes de verifications hors champs horizontal et vertical.
    private static void feuAVolonte(char colonne, char rangee) {

    }

    public static void main (String [] args) {
        initJeu();
    }
}
