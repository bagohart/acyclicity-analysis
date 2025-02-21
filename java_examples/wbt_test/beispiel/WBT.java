package beispiel;

public class WBT{
  Node root;
  
  public WBT(){
    root = null; //wahrscheinlich ist das nicht noetig, aber zum testen der Analyse evtl. nuetzlich.
  }
  
  //   5
  // 3   7
  //1 4 6 8
  public void initExample1(){
    root = new Node(5);
    root.left = new Node(3);
    root.left.left = new Node(1);
    root.left.right = new Node(4);
    root.right = new Node (7);
    root.right.left = new Node(6);
    root.right.right = new Node(8);
  }
  
  public void addFrontL(int value){
    Node oldRoot = root;
    root = new Node(value);
    root.left = oldRoot;
  }
  
  public void addBackL(int value){
    if(root == null){
      root = new Node(value);
      return;
    }
    
    Node temp = root;
    while(temp.left != null){
      temp = temp.left;
    }
    temp.left = new Node(value);
  }
  
  //haengt den rest nach links. leerer path setzt das element an den neuen root
  //im Zweifelsfalls crasht das
  public void addElementAtPath(int value, String path){
    if(root == null){
      root = new Node(value);
      return;
    }
    if(path.length() == 0){
      Node oldRoot = root;
      root = new Node(value);
      root.left = oldRoot;
      return;
    }
    Node temp = root;
    int index = 0;
    while(index < path.length()-1){
      if(path.charAt(index) == 'l'){
        temp = temp.left;
      }
      else{
        temp = temp.right;
      }
      index++;
    }
    if(path.charAt(index) == 'l'){
      Node swap = temp.left;
      temp.left = new Node(value);
      temp.left.left = swap;
    }
    else{
      Node swap = temp.right;
      temp.right = new Node(value);
      temp.right.left = swap;
    }
  }
  
  public void deleteFrontKeepL(){
    if(root == null){
      return;
    }
    root = root.left;
  }
  
  public void deleteBackL(){
    if(root == null || root.left == null){
      return;
    }
    
    Node temp = root;
    while(temp.left != null && temp.left.left != null){
      temp = temp.left;
    }
    temp.left = null;
  }
  
  //behalte linkes kind.
  //crasht wenn pfad nicht existiert.
  public void deleteAtPathKeepL(String path){
    if(path.length()==0){
      root = root == null ? null : root.left;
      return;
    }
    Node temp = root;
    int index = 0;
    while(index < path.length()-1){
      if(path.charAt(index) == 'l'){
        temp = temp.left;
      }
      else{
        temp = temp.right;
      }
      index++;
    }
    if(path.charAt(index) == 'l'){
      temp.left = temp.left.left;
    }
    else{
      temp.right = temp.right.left;
    }
  }
  
  public void swap(){
    if(root == null){
      return;
    }
    Node swap = root.left;
    root.left = root.right;
    root.right = swap;
  }
  
  //tausche die Nachfolger, nehme den linken Knoten, repeat
  public void swapLeftEdge(){
    if(root == null){
      return;
    }
    Node temp = root;
    while(temp != null){
      Node swap = temp.left;
      temp.left = temp.right;
      temp.right = swap;
      temp = temp.left;
    }
  }
  
  public void appendL(Node other){
    if(root == null){
      root = other;
      return;
    }
    Node temp = root;
    while(temp.left != null){
      temp = temp.left;
    }
    temp.left = other;
  }
  
  public void skipMiddleElements(){
    if(root == null){
      return;
    }
    while(root.left != null){
      root.left = root.left.left;
    }
    while(root.right != null){
      root.right = root.right.right;
    }
  }
  
  public void rotateSafe(){
    if(root == null || root.left == null){
      return;
    }
    Node lr = root.left.right;
    Node or = root;
    root.left.right = null;
    root = root.left;
    or.left = lr;
    root.right = or;
  }
  
  public void rotateSafeRepeat(){
    if(root == null || root.left == null){
      return;
    }
    while(root.left != null){
      Node lr = root.left.right;
      Node or = root;
      root.left.right = null;
      root = root.left;
      or.left = lr;
      root.right = or;
    }
  }
  
  public void rotateSafeToList(){
    if(root == null || root.left == null){
      return;
    }
    while(root.left != null){
      Node lr = root.left.right;
      Node or = root;
      root.left.right = null;
      root = root.left;
      or.left = lr;
      root.right = or;
    }
    
    //bisher code identisch zu rotateSafeRepeat. Jetzt wiederhole fuer alle weiter rechts.
    //wenn naechster code linken knoten hat, rotiere solange bis er das nicht mehr hat
    //sonst gehe zum naechsten knoten und wiederhole
    //iteriere bis es rechts und links keine nachfolger mehr gibt
    Node temp = root;
    //gehe bis zum ende des baumes runter
    while(temp.right != null){
      //drehe wiederholt nach rechts
      while(temp.right.left != null){
        //drehe einmal nach rechts
        //kopiert mit ersetzen
        Node lr = temp.right.left.right;
        Node or = temp.right;
        temp.right.left.right = null;
        temp.right = temp.right.left;
        or.left = lr;
        temp.right.right = or;
      }
      temp = temp.right;
    }
    
  }

  public void rotateSafeToList2(){
    if(root == null || root.left == null){
      return;
    }
    int level = 0;
    Node temp = root;
    Node former = null;
    while(temp != null){
      while(temp.left != null){
        Node lr = temp.left.right;
        Node or = temp;
        temp.left.right = null;
        temp = temp.left;
        if(level == 0){
          root = temp;
        }
        else{
          former.right = temp;
        }
        or.left = lr;
        temp.right = or;
      }
      level++;
      former = temp;
      temp = temp.right;
    }
  }
  
  public void print(){
    if(root == null){
      System.out.print("empty tree");
    }
    System.out.print("root=");
    print_rec(root);
  }
  
  public void print_rec(Node node){
    if(node == null){
      return;
    }
    System.out.print(node.value);
    System.out.print("(");
    if(node.left != null){
      System.out.print(" l=");
      print_rec(node.left);
    }
    if(node.right != null){
      System.out.print(" r=");
      print_rec(node.right);
    }
    System.out.print(" )");
  }
  
  
  private class Node{
    Node left;
    Node right;
    int value;

    public Node(){
      left = null;
      right = null;
    }

    public Node(int value){
      left = null;
      right = null;
      this.value = value;
    }
  }
}
