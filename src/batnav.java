public class batnav {

    private static final String MSG_BIENV = "Bienvenue au jeu de bataille navale!\n\n";
    private static final String MSG_ENTRER = "Entrer la description et la position des bateaux\nselon le format suivant," +
            " separes par des espaces:\ntaille[p/m/g] orientation[h/v] colonne[A-R] rangee[1-9]\nex: ghC4 mvM2 phK9\n";
    private static final String MSG_TIRER= "Feu a volonte!\n(entrer les coups a tirer: colonne [A-R] rangee [1-9])" +
            "\nex: A3 I5 M3\n";
    private static final String MSG_FIN = "Vous avez aneanti la flotte!\nAppuyer sur <Enter> pour jouer a nouveau ou" +
            "n'importe quelle autre saisie pour quitter\n";
    private static final String MSG_REVOIR = "Au revoir!";
    private static final String MSG_ERR_PLACE = "Erreur! Mauvais placement de bateaux, veuillez recommencer.\n";
    private static final String POS_COL = "  ABCDEFGHIJKLMNOPQR\n";
    private static final char [] TABLEAU_CASES = new char [162];

    private static void initJeu(){
        for (int i = 0; i < TABLEAU_CASES.length; i++) {
            TABLEAU_CASES[i] = '~';
        }
        Pep8.stro(MSG_BIENV);
        printTableau();
        Pep8.stro(MSG_ENTRER);
    }

    private static void printTableau (){
        Pep8.stro(POS_COL);
        for (int i = 0; i < 9; i++) {
            Pep8.stro((i + 1) + "|");
            for (int j = 0; j < 18; j++) {
                Pep8.charo(TABLEAU_CASES[j + i * 18]);
            }
            Pep8.stro("|\n");
        }
    }

    public static void main (String [] args){
        initJeu();
    }
}
