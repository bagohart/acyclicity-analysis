import beispiel1.Liste;

public class Test{

public static void main(String[] args){
	System.out.println("Programmstart.");

	Liste l = new Liste();
	l.addElementBack(7);
	l.addElementBack(12);
	l.addElementFront(5);
	l.addElementAtIndex(1,0);
	l.addElementAtIndex(13,6);
	l.addElementAtIndex(6,2);
	l.print();

	System.out.println("");
	Liste l2 = new Liste();
	l2.addElementBack(100);
	l2.addElementBack(200);
	l2.addElementBack(300);
	l2.print();

	System.out.println("");
	l.append(l2.getFirstNode());
	l.print();

	System.out.println("\nJetzt reversen!!!");
	l.reverse_cf();
	l.print();
	
	System.out.println("\nProgrammende.");
}

}
