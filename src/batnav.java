/**
 * Cette classe contient un main et des methodes pour jouer au jeu de bataille
 * navale. Le jeu est joué par un seul joueur. Le joueur commence par placer des
 * navires sur une grille, puis il leur tire dessus. Egalement, cette classe est
 * facilement transposable en Pep/8.
 *
 * @author William Chretien,       Code permanent : CHRW15109406
 *
 * @author Ricardo Ruy Valle-Mena, Code permanent : VALR29129407
 *
 * @version 2019-11-03
 */
public class batnav {

    // Constantes
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
    private static final int TAILLE_STRINGS = 900;

    public static void main(String [] args) {
        char [] rejouer = new char[TAILLE_STRINGS];
        do {
            initTableau();
            Pep8.stro(MSG_BIENV);
            printTableau();
            Pep8.stro(MSG_ENTRER);
            placerBateaux();
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
            for (int j = 0; j < 18; j++) {
                Pep8.charo(TABLEAU_CASES[j + mult(i, 18)]);
            }
            Pep8.stro("|\n");
        }
    }


    /**
     * Verifie que les descriptions des bateaux entres par l'utilisateur sont
     * conformes a l'enonce. C'est a dire qu'il y a seulement un espace entre chaque
     * descripteur de bateaux et que ce descripteur ait 4 caracteres. Le nombre
     * d'espaces que l'utilisateur doit rentrer est `nbBateaux` - 1 et ceux-ci
     * doivent etre entre chaque description de bateaux.
     */
    private static void placerBateaux() {
        char [] descripteurBateaux = creerDescripteur();
        char separateurBateaux;
        int nbBateaux = 0;
        int i = 0;

        do {
            if (verifierDescripteur(descripteurBateaux, i)) {
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
     * Place un bateau dans le tableau en changeant le charactere representant l'eau
     * par celui de l'orientation du bateau.
     *
     * @param grandeur    la grandeur que couvrira le bateau.
     * @param orientation l'orientation du bateau.
     * @param colonne     la colonne dont le bateau commence.
     * @param rangee      la rangee dont le bateau commence.
     */
    private static void placerBateau(int grandeur, char orientation, int colonne, int rangee) {
        if (verifierPlacementBateau(grandeur, orientation, colonne, rangee)) {
            if (orientation == '>') {
                for (int i = 0; i < grandeur; i++) {
                    TABLEAU_CASES[colonne + mult(rangee, 18) + i] = orientation;
                }
            } else {
                for (int i = 0; i < grandeur; i++) {
                    TABLEAU_CASES[colonne + mult(rangee, 18) + mult(i, 18)] = orientation;
                }
            }
        }
    }


    private static int mult(int a, int b) {
        int resultat = 0;
        for (int i = 0; i < b; i++) resultat += a;
        return resultat;
    }


    /**
     *
     * @param descripteur   contient la description de tous les bateaux
     *                      placés par le joueur.
     * @param indexeDeBase  l'indexe à partir duquel on trouve la description
     *                      du bateau qu'on vérifie.
     * @return si le descripteur du bateau trouvé à indexeDeBase est correct
     */
    private static boolean verifierDescripteur(char [] descripteur,
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
     * Solicite l'utilisateur a entrer les feux a tirer sur les bateaux.
     */
    private static void feuAVolonte() {
        printTableau();
        Pep8.stro(MSG_TIRER);
        while (verifierBateauPresent()) {
            verifierDescriptionFeux();
        }
    }


    /**
     * Verifie que les feux entres par l'utilisateur sont conformes a l'enonce.
     * C'est a dire qu'il y a seulement un espace entre chaque descripteur de feux
     * et que ce descripteur ait 2 caracteres. Le nombre d'espaces que l'utilisateur
     * doit rentrer est `nbFeux` - 1 et ceux-ci doivent etre place entre chaque
     * description de feux.
     */
    private static void verifierDescriptionFeux() {
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
        retrouverFeux(descripteurFeux, nbFeux);
    }


    /**
     * Divise un descripteur de facon de retrouver la description de chacun des feux
     * entres.
     *
     * @param descripteurFeux un tableau de plusieurs descriptions de feux.
     * @param nbFeux          le nombre de feux que le descripteur contient.
     */
    private static void retrouverFeux(char[] descripteurFeux, int nbFeux) {
        for (int i = 0; i < nbFeux; i++) {
            placerFeux(changerNbColonne(descripteurFeux[mult(i, 3)]),
                       changerNbRangee( descripteurFeux[mult(i, 3) + 1]));
            printTableau();
        }
    }


    /**
     * Place un feu dans le tableau en changeant le charactere representant l'eau ou
     * bateaux par celui d'un feu rate ou touche. Un bateau touche par un feu cree 4
     * debris chacun similaire a l'effet d'un feu, on l'utilise donc de la recursion
     * pour creer cette effet a ces cases.
     *
     * @param colonne la position du feu par rapport a la colonne.
     * @param rangee  la position du feu par rapport a la rangee.
     */
    private static void placerFeux(int colonne, int rangee) {
        if (verifierHorsChamps(colonne, rangee)) {
            if (verifierBateauPresent(colonne, rangee)) {
                TABLEAU_CASES[colonne + mult(rangee, 18)] = '*';
                placerFeux(colonne + 1, rangee);
                placerFeux(colonne - 1, rangee);
                placerFeux(colonne, rangee + 1);
                placerFeux(colonne, rangee - 1);
            } else if (TABLEAU_CASES[colonne + mult(rangee, 18)] != '*') {
                TABLEAU_CASES[colonne + mult(rangee, 18)] = 'o';
            }
        }
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
                        (TABLEAU_CASES[colonne + mult(rangee, 18) + i] != '~')) {
                    placementValide = false;
                }
            } else if (!verifierHorsChamps(colonne, rangee + i) ||
                    (TABLEAU_CASES[colonne + mult(rangee, 18) + mult(i, 18)] != '~')) {
                placementValide = false;
            }
        }
        return placementValide;
    }


    /**
     * Verifie si le caractere entre par l'utilisateur representant la grandeur est
     * valide.
     *
     * @param grandeur
     * @return
     */
    private static boolean verifierGrandeur(char grandeur) {
        return grandeur == 'p' || grandeur == 'm' || grandeur == 'g';
    }


    /**
     * Verifie si le caractere entre par l'utilisateur representant l'orientation
     * est valide.
     *
     * @param orientation
     * @return
     */
    private static boolean verifierOrientation(char orientation) {
        return orientation == 'h' || orientation == 'v';
    }


    /**
     * Verifie si le caractere entre par l'utilisateur representant la colonne est
     * valide.
     *
     * @param colonne
     * @return
     */
    private static boolean verifierColonne(char colonne) {
        return colonne >= 'A' && colonne <= 'R';
    }


    /**
     * Verifie si le caractere entre par l'utilisateur representant la rangee est
     * valide.
     *
     * @param rangee
     * @return
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
        return TABLEAU_CASES[colonne + mult(rangee, 18)] == 'v' ||
               TABLEAU_CASES[colonne + mult(rangee, 18)] == '>';
    }


    /**
     * Verifie si une position colonne/rangee est a l'interieur du tableau du jeu.
     *
     * @param colonne la position en colonne.
     * @param rangee  la position en rangee.
     * @return si la position est a l'interieur du tableau du jeu ou non.
     */
    private static boolean verifierHorsChamps(int colonne, int rangee) {
        return (colonne + mult(rangee, 18) < mult(rangee + 1, 18))
                && (colonne + mult(rangee, 18) >= 18 + mult(rangee - 1, 18))
                && (colonne + mult(rangee, 18) < 162)
                && (colonne + mult(rangee, 18) >= 0);
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


}
