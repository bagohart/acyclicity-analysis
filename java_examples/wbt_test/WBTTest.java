import beispiel.WBT;

public class WBTTest{
  public static void main(String[] args){
    System.out.println("Programmstart.");
    
    WBT t = new WBT();
    t.initExample1();
    t.print();
    System.out.println("");
    
    // Adding elements
    System.out.println("addFrontL 0");
    t.addFrontL(0);
    t.print();
    System.out.println("");
    System.out.println("addBackL 13");
    t.addBackL(13);
    t.print();
    System.out.println("");
    System.out.println("addElementAtPath 20, ll");
    t.addElementAtPath(20, "ll");
    t.print();
    System.out.println("");
    
    // Removing Elements
    System.out.println("deleteFrontKeepL");
    t.deleteFrontKeepL();
    t.print();
    System.out.println("");
    System.out.println("deleteBackL");
    t.deleteBackL();
    t.print();
    System.out.println("");
    
    System.out.println("deleteAtPathKeepL r");
    t.deleteAtPathKeepL("r");
    t.print();
    System.out.println("");
    
    //swapping elements
    System.out.println("swap");
    t.swap();
    t.print();
    System.out.println("");
    
    System.out.println("swapLeftEdge");
    t.swapLeftEdge();
    t.print();
    System.out.println("");
    
    //skipmiddleelements
    System.out.println("skipMiddleElements");
    t.skipMiddleElements();
    t.print();
    System.out.println("");
    
    System.out.println("t2 ab jetzt");
    WBT t2 = new WBT();
    t2.initExample1();
    t2.print();
    System.out.println("");
    
    System.out.println("rotateSafe");
    t2.rotateSafe();
    t2.print();
    System.out.println("");
    
    System.out.println("rotateSafeRepeat");
    t2.rotateSafeRepeat();
    t2.print();
    System.out.println("");
    
    t2.initExample1();
    System.out.println("t2 reset:");
    t2.print();
    System.out.println("");
    System.out.println("rotateSafeToList");
    t2.rotateSafeToList();
    t2.print();
    System.out.println("");
    
    t2.initExample1();
    System.out.println("t2 reset:");
    t2.print();
    System.out.println("");
    System.out.println("rotateSafeToList2");
    t2.rotateSafeToList2();
    t2.print();
    System.out.println("");
    
    System.out.println("\nProgrammende.");
  }
}

