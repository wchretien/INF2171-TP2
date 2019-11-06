/**
 * Cette classe contient un main et des methodes pour jouer au jeu de bataille
 * navale. Le jeu est joué par un seul joueur. Le joueur commence par placer des
 * navires sur une grille, puis il leur tire dessus. Egalement, cette classe est
 * facilement transposable en Pep/8.
 *
 * @author William Chretien,       Code permanent : CHRW15109406
 * @author Ricardo Ruy Valle-Mena, Code permanent : VALR29129407
 *
 * @version 2019-11-03
 */
public class batnav {

    // Constantes
    private static final String MSG_BIENV = "Bienvenue au jeu de bataille navale!\n\n";
    private static final String MSG_ENTRER =
        "Entrer la description et la position des bateaux\nselon le format " +
        "suivant, separes par des espaces:\ntaille[p/m/g] orientation[h/v] " +
        "colonne[A-R] rangee[1-9]\nex: ghC4 mvM2 phK9\n";
    private static final String MSG_TIRER =
        "Feu a volonte!\n(entrer les coups a tirer: colonne [A-R] rangee " +
        "[1-9])\nex: A3 I5 M3\n";
    private static final String MSG_ERR_TIRER =
        "Erreur! Mauvais placement de tires, veuillez recommencer.\n";
    private static final String MSG_FIN =
        "Vous avez aneanti la flotte!\nAppuyer sur <Enter> pour jouer a " +
        "nouveau ou \nn'importe quelle autre saisie pour quitter.\n";
    private static final String MSG_REVOIR = "Au revoir!";
    private static final String MSG_ERR_PLACE =
        "Erreur! Mauvais placement de bateaux, veuillez recommencer.\n";
    private static final String POS_COL = "  ABCDEFGHIJKLMNOPQR\n";
    private static final int NB_COLONNES = 18;
    private static final int NB_CASES = 162;
    private static final char [] TABLEAU_CASES = new char [NB_CASES];
    private static final int TAILLE_STRINGS = 900;

    public static void main(String [] args) {
        char [] rejouer;
        do {
            initTableau();
            Pep8.stro(MSG_BIENV);
            printTableau();
            Pep8.stro(MSG_ENTRER);
            verifierBateauxEntres();
            feuAVolonte();
            Pep8.stro(MSG_FIN);
            rejouer = creerDescripteur();
        } while (rejouer[0] == '\n');
        Pep8.stro(MSG_REVOIR);
    }


    /**
     * Initialise le tableau sur lequel se joue le jeu avec des cases
     * considerees vides.
     */
    private static void initTableau() {
        for (int i = 0; i < TABLEAU_CASES.length; i++) {
            TABLEAU_CASES[i] = '~';
        }
    }


    /**
     * Affiche le tableau du jeu de la maniere requise pour jouer au jeu.
     */
    private static void printTableau() {
        Pep8.stro(POS_COL);
        for (int i = 0; i < 9; i++) {
            Pep8.stro((i + 1) + "|");
            for (int j = 0; j < NB_COLONNES; j++) {
                Pep8.charo(TABLEAU_CASES[j + mult(i, NB_COLONNES)]);
            }
            Pep8.stro("|\n");
        }
    }


    /**
     * Verifie que les bateaux entres par l'utilisateur sont conformes a l'enonce.
     * C'est a dire qu'il y a un espace entre chaque descripteur de bateaux et
     * que ce descripteur ait 4 caracteres.
     *
     * Une fois les descriptions vérifiées, place les bateaux décrits sur le
     * tableau.
     */
    private static void verifierBateauxEntres() {
        char [] descripteurBateaux = creerDescripteur();
        char separateurBateaux;
        int nbBateaux = 0;
        int i = 0;

        do {
            if (verifierDescripteurBateau(descripteurBateaux, i)) {
                nbBateaux++;
                separateurBateaux = descripteurBateaux[i + 4];
                i += 5;
            } else {
                Pep8.stro(MSG_ERR_PLACE);
                descripteurBateaux = creerDescripteur();
                nbBateaux = 0;
                separateurBateaux = 0;
                i = 0;
            }
        } while (separateurBateaux != '\n');

        for (i = 0; i < nbBateaux; i++) {
            placerBateau(changerNbGrandeur(descripteurBateaux[mult(i, 5)]),
                changerCharOrien(descripteurBateaux[mult(i, 5) + 1]),
                changerNbColonne(descripteurBateaux[mult(i, 5) + 2]),
                changerNbRangee( descripteurBateaux[mult(i, 5) + 3]));
        }
    }


    /**
     * Verifie que le descripteur d'un bateau a l'indexe indique est valide.
     *
     * @param descripteur   contient la description de tous les bateaux
     *                      placés par le joueur.
     * @param indexeDeBase  l'indexe à partir duquel on trouve la description
     *                      du bateau qu'on vérifie.
     * @return si le descripteur du bateau trouvé à indexeDeBase est correct
     */
    private static boolean verifierDescripteurBateau(char [] descripteur,
                                                     int indexeDeBase) {
        char grandeur    = descripteur[indexeDeBase];
        char orientation = descripteur[indexeDeBase + 1];
        char colonne     = descripteur[indexeDeBase + 2];
        char rangee      = descripteur[indexeDeBase + 3];
        return verifierGrandeur(grandeur) &&
                verifierOrientation(orientation) &&
                verifierColonne(colonne) && verifierRangee(rangee);
    }


    /**
     * Place un bateau dans le tableau en changeant le charactere representant l'eau
     * par celui de l'orientation du bateau.
     *
     * @param grandeur    la grandeur que couvrira le bateau.
     * @param orientation l'orientation du bateau.
     * @param colonne     la colonne dont le bateau commence.
     * @param rangee      la rangee dont le bateau commence.
     */
    private static void placerBateau(int grandeur, char orientation,
                                     int colonne, int rangee) {
        if (verifierPlacementBateau(grandeur, orientation, colonne, rangee)) {
            if (orientation == '>') {
                for (int i = 0; i < grandeur; i++) {
                    TABLEAU_CASES[colonne + mult(rangee, NB_COLONNES) + i] = orientation;
                }
            } else {
                for (int i = 0; i < grandeur; i++) {
                    TABLEAU_CASES[colonne +
                                  mult(rangee, NB_COLONNES) +
                                  mult(i, NB_COLONNES)] = orientation;
                }
            }
        }
    }


    /**
     * Verifie qu'un bateau peut etre entre dans le tableau et qu'il ne rentre pas
     * en collision avec un autre.
     *
     * @param grandeur    la grandeur du bateau.
     * @param orientation l'orientation du bateau.
     * @param colonne     la position en colonne du bateau.
     * @param rangee      la position en rangee du bateau.
     * @return si le bateau peut etre place a cette endroit.
     */
    private static boolean verifierPlacementBateau(int grandeur, char orientation,
                                                   int colonne, int rangee) {
        boolean placementValide = true;
        for (int i = 0; i < grandeur; i++) {
            if (orientation == '>') {
                if (!verifierHorsChamps(colonne + i, rangee) ||
                        (TABLEAU_CASES[colonne + mult(rangee, NB_COLONNES) + i] != '~')) {
                    placementValide = false;
                }
            } else if (!verifierHorsChamps(colonne, rangee + i) ||
                    (TABLEAU_CASES[colonne +
                            mult(rangee, NB_COLONNES) +
                            mult(i, NB_COLONNES)] != '~')) {
                placementValide = false;
            }
        }
        return placementValide;
    }


    /**
     * Solicite l'utilisateur a entrer les feux a tirer sur les bateaux,
     * jusqu'à la fin du jeu.
     */
    private static void feuAVolonte() {
        char [] descripteurFeux;
        printTableau();
        Pep8.stro(MSG_TIRER);
        while (verifierBateauPresent()) {
            descripteurFeux = creerDescripteur();
            while (!verifierFeuxEntres(descripteurFeux)) {
                descripteurFeux = creerDescripteur();
            }
            int nbFeux = compterNbFeux(descripteurFeux);
            placerFeux(descripteurFeux, nbFeux);
        }
    }


    /**
     * Verifie que les feux entres par l'utilisateur sont conformes a l'enonce.
     * C'est a dire qu'il y a un espace entre chaque descripteur de feux et que
     * la description d'un feux ait 2 caracteres.
     *
     * @param descripteurFeux le descripteur des feux
     */
    private static boolean verifierFeuxEntres(char [] descripteurFeux) {
        char separateurFeux = 0;
        for (int i = 0; separateurFeux != '\n'; i += 3) {
            if (!(verifierColonne(descripteurFeux[i]) &&
                    verifierRangee(descripteurFeux[i + 1]))) {
                Pep8.stro(MSG_ERR_TIRER);
                return false;
            }
            separateurFeux = descripteurFeux[i + 2];
        }
        return true;
    }


    /**
     * Place les feux spécifiés sur le tableau.
     *
     * @param feux description des feux à placer, après validation
     * @param nb   le nombre de feux à placer
     */
    private static void placerFeux(char [] feux, int nb) {
        int colonne, rangee;
        for (int i = 0; i < nb; i++) {
            colonne = changerNbColonne(feux[mult(i, 3)]);
            rangee  = changerNbRangee( feux[mult(i, 3) + 1]);
            tirerFeu(colonne, rangee);
            printTableau();
        }
    }


    /**
     * Tire un feu dans le tableau en changeant le charactere representant l'eau ou
     * bateaux par celui d'un feu rate ou touche. Un bateau touche par un feu cree 4
     * debris chacun similaire a l'effet d'un feu, on utilise donc de la recursion
     * pour creer cet effet a ces cases.
     *
     * @param colonne la colonne où on tire le feu
     * @param rangee  la rangée où on tire le feu
     */
    private static void tirerFeu(int colonne, int rangee) {
        if (verifierHorsChamps(colonne, rangee)) {
            if (verifierBateauPresent(colonne, rangee)) {
                TABLEAU_CASES[colonne + mult(rangee, NB_COLONNES)] = '*';
                tirerFeu(colonne + 1, rangee);
                tirerFeu(colonne - 1, rangee);
                tirerFeu(colonne, rangee + 1);
                tirerFeu(colonne, rangee - 1);
            } else if (TABLEAU_CASES[colonne + mult(rangee, NB_COLONNES)] != '*') {
                TABLEAU_CASES[colonne + mult(rangee, NB_COLONNES)] = 'o';
            }
        }
    }
    

    /**
     * Compte le nombre de feux dans le descripteur donné.
     *
     * @param descripteurFeux une description valide d'au moins un feu
     * @return le nombre de feux dans la description
     */
    private static int compterNbFeux(char [] descripteurFeux) {
        return verifierNbEspaces(descripteurFeux) + 1;
    }


    /**
     * Cree un lecteur de String similaire a celui qu'on devra utiliser en Pep/8.
     *
     * @return un tableau contenant tous les caracteres de la phrase entree.
     */
    private static char[] creerDescripteur() {
        char[] descripteur = new char[TAILLE_STRINGS];
        int i = 0;

        do {
            descripteur[i] = Pep8.chari();
            i++;
        } while (descripteur[i - 1] != '\n');
        return descripteur;
    }


    /**
     * Change le caractere de la colonne pour sa valeur en int, facilitant le calcul
     * des positions.
     *
     * @param colonne la colonne a changer en int.
     * @return la valeur de la colonne en int.
     */
    private static int changerNbColonne(char colonne) {
        return colonne - 'A';
    }


    /**
     * Change le caractere de la rangee pour sa valeur en int, facilitant le calcul
     * des positions.
     *
     * @param rangee la rangee a changer en int.
     * @return la valeur de la rangee en int.
     */
    private static int changerNbRangee(char rangee) {
        return rangee - '1';
    }


    /**
     * Change le caractere de la grandeur pour sa valeur en int, facilitant la
     * position des bateaux.
     *
     * @param grandeur la grandeur a changer en int.
     * @return la valeur de la grandeur en int.
     */
    private static int changerNbGrandeur(char grandeur) {
        int nbCases;
        switch (grandeur) {
            case 'p':
                nbCases =1;
                break;
            case 'm':
                nbCases = 3;
                break;
            default:
                nbCases = 5;
                break;
        }
        return nbCases;
    }


    /**
     * Change le caractere de l'orientation pour un caractere plus representatif
     * visuellement, facilitant la comprehension de la position des bateaux dans le
     * tableau.
     *
     * @param orientation l'orientation dont on veut changer son caractere.
     * @return le caractere representatif de l'orientation.
     */
    private static char changerCharOrien(char orientation) {
        char orientationAffichage = 'v';
        if (orientation == 'h') {
            orientationAffichage = '>';
        }
        return orientationAffichage;
    }


    /**
     * Verifie si le caractere entre par l'utilisateur representant la grandeur est
     * valide.
     *
     * @param grandeur
     * @return booléen indiquant si la grandeur est valide
     */
    private static boolean verifierGrandeur(char grandeur) {
        return grandeur == 'p' || grandeur == 'm' || grandeur == 'g';
    }


    /**
     * Verifie si le caractere entre par l'utilisateur representant l'orientation
     * est valide.
     *
     * @param orientation
     * @return booléen indiquant si l'orientation est valide
     */
    private static boolean verifierOrientation(char orientation) {
        return orientation == 'h' || orientation == 'v';
    }


    /**
     * Verifie si le caractere entre par l'utilisateur representant la colonne est
     * valide.
     *
     * @param colonne
     * @return booléen indiquant si la colonne est valide
     */
    private static boolean verifierColonne(char colonne) {
        return colonne >= 'A' && colonne <= 'R';
    }


    /**
     * Verifie si le caractere entre par l'utilisateur representant la rangee est
     * valide.
     *
     * @param rangee
     * @return booléen indiquant si la rangée est valide
     */
    private static boolean verifierRangee(char rangee) {
        return rangee >= '1' && rangee <= '9';
    }


    /**
     * Verifie si au moins un bateau est present dans le tableau.
     *
     * @return true si au moins un bateau est present.
     */
    private static boolean verifierBateauPresent() {
        for (int i = 0; i < TABLEAU_CASES.length; i++) {
            if (TABLEAU_CASES[i] == 'v' || TABLEAU_CASES[i] == '>') {
                return true;
            }
        }
        return false;
    }


    /**
     * Verifie si un bateau est present a un endroit specifique dans le tableau.
     *
     * @param colonne la position du bateau en colonne.
     * @param rangee  la position du bateau en rangee.
     * @return si un bateau est present a cet endroit.
     */
    private static boolean verifierBateauPresent(int colonne, int rangee) {
        return TABLEAU_CASES[colonne + mult(rangee, NB_COLONNES)] == 'v' ||
               TABLEAU_CASES[colonne + mult(rangee, NB_COLONNES)] == '>';
    }


    /**
     * Verifie si une position colonne/rangee est a l'interieur du tableau du jeu.
     *
     * @param colonne la position en colonne.
     * @param rangee  la position en rangee.
     * @return si la position est a l'interieur du tableau du jeu ou non.
     */
    private static boolean verifierHorsChamps(int colonne, int rangee) {
        return (colonne + mult(rangee, NB_COLONNES) < mult(rangee + 1, NB_COLONNES))
                && (colonne + mult(rangee, NB_COLONNES) >=
                   NB_COLONNES + mult(rangee - 1, NB_COLONNES))
                && (colonne + mult(rangee, NB_COLONNES) < NB_CASES)
                && (colonne + mult(rangee, NB_COLONNES) >= 0);
    }


    /**
     * Compte le nombre d'espaces contenu dans une description de bateaux.
     *
     * @param descripteurBateaux un tableau conteant la description de bateaux.
     * @return le nombre d'espaces.
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
     * Implémentation de la multiplication par une série d'additions.
     * La multiplication n'existe pas en Pep8. Il est important de
     * l'implémenter de la sorte en Java pour faciliter son implémentation en
     * Pep8.
     *
     * @param a une des opérandes de la multiplication
     * @param b l'autre opérande de la multiplication
     * @return le résultat de la multiplication
     */
    private static int mult(int a, int b) {
        int resultat = 0;
        for (int i = 0; i < b; i++) resultat += a;
        return resultat;
    }


}
