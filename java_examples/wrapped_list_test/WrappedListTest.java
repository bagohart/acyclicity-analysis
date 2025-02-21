import beispiel.WrappedList;

public class WrappedListTest{
  public static void main(String[] args){
    System.out.println("Programmstart.");
    
    // Adding elements
    WrappedList l = new WrappedList();
    l.addElementBack(7);
    l.addElementBack(12);
    l.addElementFront(5);
    l.addElementAtIndex(1,0);
    l.addElementAtIndex(13,6);
    l.addElementAtIndex(6,2);
    l.print();
    
    System.out.println("");
    WrappedList l2 = new WrappedList();
    l2.addElementBack(100);
    l2.addElementBack(200);
    l2.addElementBack(300);
    l2.print();
    
    System.out.println("");

    // Append another list
    l.append(l2.getFirstNode());
    l.print();
    
    // Reverse the list
    System.out.println("\nJetzt reversen!!!");
    l.reverse_cf();
    l.print();

    // Deleting elements
    l.deleteElementBack();
    l.deleteElementBack();
    l.deleteElementBack();
    l.deleteElementBack();
    l.deleteElementBack();
    l.deleteElementBack();
    System.out.println("");
    l.print();
    System.out.println("");

    l.reverse_cf();
    l.print();
    System.out.println("");

    WrappedList l3 = new WrappedList();
    l3.addElementFront(3);
    l3.addElementFront(2);
    l3.addElementFront(1);
    l3.print();
    System.out.println("");

    // merge with another list
    l.merge_unsafe(l3.getFirstNode());
    l.print();
    System.out.println("");

    // unmerge again
    //WrappedList l4 = l.unmerge();
    l.unmerge();
    l.print();
    System.out.println("");
    //l4print();
    System.out.println("");

    //shift once to the right
    l.shift_safe();
    l.print();
    System.out.println("");

    // merge again, then unmerge and add first element from B-list to last element
    l.addElementBack(400);
    l.print();
    System.out.println("");
    l.unmerge_weird();
    l.print();
    System.out.println("");

    // set head to last element
    l.skipMiddleElements();
    l.print();
    System.out.println("");

    //unmerge, merge again
    l.addElementBack(400);
    l.addElementBack(500);
    l.print();
    System.out.println("");
    System.out.println("unmerge, merge");
    l.unmergeMerge();
    l.print();
    System.out.println("full circle shift");
    l.shift_full_circle();
    l.print();
    
    System.out.println("\nProgrammende.");
  }
}

