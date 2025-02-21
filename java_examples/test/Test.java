//package lists;
//package lists;

public class Test{
  Node head;
  
  public Test(){
    head = null; //wahrscheinlich ist das nicht noetig, aber zum testen der Analyse evtl. nuetzlich.
  }
  
  public void testMethod(){
    head = new Node(5);
    head.n = new Node(15);
    head.n.o = null;
    head.n.m = new Node (25);
  }
  
  private class Node{
    Node n;
    Node m;
    Node o;
    int value;

    public Node(){
      n = null;
      m = null;
      o = null;
    }

    public Node(int value){
      n = null;
      m = null;
      o = null;
      this.value = value;
    }
  }
}
