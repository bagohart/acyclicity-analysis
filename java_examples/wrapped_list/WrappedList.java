//package lists;

public class WrappedList{
  Node head;
  
  public WrappedList(){
    head = null; //wahrscheinlich ist das nicht noetig, aber zum testen der Analyse evtl. nuetzlich.
  }
  
  public void init(int[] initValues){
    if(initValues.length == 0){
      head = null;
    }
    else{
      head = new Node(initValues[0]);
      Node akt = head;
      for( int i = 1; i < initValues.length ; i++){
        akt.next = new Node(initValues[i]);
        akt = akt.next;
      }
    }
  }
  
/*  public void addElementFront(int value){
    if(head == null){
      head = new Node(value);
    }
    else{
      Node newHead = new Node(value);
      newHead.next = head;
      head = newHead;
    }
  }*/
   public void addElementFront(int value){
      Node newHead = new Node(value);
      newHead.next = head;
      head = newHead;
   }
  
  public void addElementBack(int value){
    if(head == null){
      head = new Node(value);
    }
    else{
      Node last = head;
      while(last.next != null){
        last = last.next;
      }
      last.next = new Node(value);
    }
  }
  
  // If index < length of list, add element at the end of the list
  public void addElementAtIndex(int value, int index){
    if(index < 0){
      return;
    }
    else if(head == null){
      head = new Node(value);
      return;
    }
    else if(index == 0){
      Node temp = head;
      head = new Node(value);
      head.next = temp;
    }
    else{
      Node temp = head;
      while((index-1) > 0){
        index--;
        if(temp.next != null){
          temp = temp.next;
        }
        else{
          break;
        }
      }
      Node temp2 = temp.next;
      temp.next = new Node(value);
      temp.next.next = temp2;
    }
  }
  
  
  public void deleteElementFront(){
    if(head == null){
      return;
    }
    else{
      head = head.next;
    }
  }
  
  
  public void deleteElementBack(){
    if(head == null){
      return;
    }
    else if(head.next == null){
      head = null;
    }
    else{
      Node temp = head;
      while(temp.next.next != null){
        temp = temp.next;
      }
      temp.next = null;
    }
  }
  
  // If Index is invalid, don't delete anything
  public void deleteElementAtIndex(int index){
    if(index < 0){
      return;
    }
    else if(index == 0){
      if(head!=null){
        head = head.next;
      }
    }
    else{
      Node beforeDeleteGoal = head;
      while((index-1)>0){
        index--;
        if(beforeDeleteGoal.next != null){
          beforeDeleteGoal = beforeDeleteGoal.next;
        }
        else{
          return;
        }
      }
      if(beforeDeleteGoal.next != null){
        beforeDeleteGoal.next = beforeDeleteGoal.next.next;
      }
    }
  }
  
  public Node getFirstNode(){
    return head;
  }
  
  public boolean isEmpty(){
    if(head==null){
      return true;
    }
    else{
      return false;
    }
  }
  
  public void append(Node andereListe){
    if(head == null){
      head = andereListe;
    }
    else{
      Node temp = head;
      while(temp.next != null){
        temp = temp.next;
      }
      temp.next = andereListe;
    }
  }
  
  public void print(){
    Node temp = head;
    while(temp != null){
      System.out.print(temp.value);
      System.out.print(" ");
      temp = temp.next;
    }
  }
  
  public void reverse_cf(){
    if(head == null){
      return;
    }
    
    Node p = head;
    Node c = head.next;
    Node headkopie = head;
    p.next = null;
    while(c != null){
      head = c;
      headkopie = c.next;
      c.next = p;
      p = c;
      c = headkopie;
    }
  }	

//mit leichter umformulierung (start bei temp=head) eventuell nicht mehr beweisbar. mal ausprobieren. (siehe v2)
  public void skipMiddleElements(){
    if(head == null || head.next == null){
      return;
    }

    Node temp = head.next;
    while(temp.next != null){
      temp = temp.next;
    }
    head.next = temp;
  }

//nicht beweisbar.
  public void skipMiddleElements_v2(){
    if(head == null){
      return;
    }

    if(head.next == null){
      return;
    }

    Node temp = head;
    while(temp.next != null){
      temp = temp.next;
    }
    head.next = temp;
  }

//kA was hier passiert, wenn Liste ungerade ist oder so?
  //public void unmerge_dropB_add2ndElementBack(){
  public void unmerge_weird(){
    if(head == null || head.next == null || head.next.next == null){
      return;
    }

    Node temp = head;
    Node n2 = head.next;
    while(temp.next != null && temp.next.next != null){
      temp.next = temp.next.next;
      temp = temp.next;
    }
    n2.next = null;
    temp.next = n2;
  }

//ob das tut?
  public Node unmerge(){
    if(head == null || head.next == null){
      return null;
    }
    Node other = head.next;
    Node cur = head;
    Node temp;
    while(cur.next.next != null){
      temp = cur.next;
      cur.next = cur.next.next;
      cur = temp;
    }
    cur.next = null;
    return other;
  }

  // shifts the head of the list to its direct successor, preserving acyclicity at every step.
  public void shift_safe(){
    if(head == null || head.next == null){
      return;
    }

    Node old_head = head;
    head = head.next;
    Node temp = head;
    while(temp.next != null){
      temp = temp.next;
    }
    old_head.next = null;
    temp.next = old_head;
  }

  // shifts the head of the list to its direct successor, preserving acyclicity at every step, breaking link earlier than in v1.
  public void shift_safe_v2(){
    if(head == null || head.next == null){
      return;
    }

    Node old_head = head;
    head = head.next;
    old_head.next = null;
    Node temp = head;
    while(temp.next != null){
      temp = temp.next;
    }
    temp.next = old_head;
  }

  //undefined behaviour if the other list doesn't have the same length
  public void merge_unsafe(Node other){
    Node self = this.head;
    Node self_next, other_next;
    while(self != null){
      self_next = self.next;
      other_next = other.next;
      self.next = other;
      other.next = self_next;
      self = self_next;
      other = other_next;
    }
  }

  //swap. higher > lower, or untested behaviour.
//weirde dinge passieren in analyse. o_O
  public void swap(int lower, int higher){
    Node beforeLower, beforeHigher;
    if(lower == 0){
      Node lowerNode = this.head;
      Node afterLower = this.head.next;
      int index = 0;
      beforeHigher = this.head;
      while(index < higher - 1){
        beforeHigher = beforeHigher.next;
        index++;
      }
      Node higherNode = beforeHigher.next;
      lowerNode.next = higherNode.next;
      beforeHigher.next = lowerNode;
      higherNode.next = afterLower;
      this.head = higherNode;
    }
  }
  
  //not safe
  public void swap_neighbours(int index){
    if(index == 0){
      Node old = head;
      head = head.next;
      old.next = head.next;
      head.next = old;
    }
    else{
      Node temp = head;
      while(index-1 > 0){
        temp = temp.next;
      }
      Node old = temp.next;
      temp.next = temp.next.next;
      old.next = temp.next.next;
      temp.next.next = old;
    }
  }

  //pos 0 = append after first element
  //scheint zu gehen
  public void appendMiddle(Node otherList, int pos){
    Node last = this.head;
    int index = 0;
    while(index < pos){
      last = last.next;
    }
    Node again = last.next;
    last.next = otherList;
    Node otherEnd = otherList;
    while(otherEnd.next != null){
      otherEnd = otherEnd.next;
    }
    otherEnd.next = again;
  }
  
  public void unmergeMerge(){
    Node other = head.next;
    Node cur = head;
    Node temp;
    while(cur.next.next != null){
      temp = cur.next;
      cur.next = cur.next.next;
      cur = temp;
    }
    cur.next = null;
    //return other;

    Node self = this.head;
    Node self_next, other_next;
    while(self != null){
      self_next = self.next;
      other_next = other.next;
      self.next = other;
      other.next = self_next;
      self = self_next;
      other = other_next;
    }
  }

  public void shift_full_circle(){
    Node original_start = this.head;
    Node last_shift = this.head.next;

    while(original_start != last_shift){
      Node old_head = head;
      head = head.next;
      Node temp = head;
      while(temp.next != null){
        temp = temp.next;
      }
      old_head.next = null;
      temp.next = old_head;

      last_shift = head;
    }
  }

  //TODO: swapsafe, liste in mitte einfuegen, merge_safe, evtl. beweisbare variante fuer unmergeAndAppend finden

  //Ab hier komplexe beispiele, um aprove's statespace explodieren zu lassen
  public void bubble(){
    Node nh = head.next;
    head.next = nh.next;
    nh.next = head;
    head = nh;
    Node p = head;
    Node f = head.next;
    Node s = head.next.next;
    while(s.next != null){
      p.next = s;
      f.next = s.next;
      s.next = f;
      p = s;
      s = f.next;
    }
  }
  
  public Node appendUnmerge(Node andereListe){
    //append
    if(head == null){
      head = andereListe;
    }
    else{
      Node temp = head;
      while(temp.next != null){
        temp = temp.next;
      }
      temp.next = andereListe;
    }
    //unmerge
    if(head == null || head.next == null){
      return null;
    }
    Node other = head.next;
    Node cur = head;
    Node temp;
    while(cur.next.next != null){
      temp = cur.next;
      cur.next = cur.next.next;
      cur = temp;
    }
    cur.next = null;
    return other;
  }
  
  public void reverseDeleteShift(){    
    while(head != null){ 
      //reverse
      Node p = head;
      Node c = head.next;
      Node headkopie = head;
      p.next = null;
      while(c != null){
        head = c;
        headkopie = c.next;
        c.next = p;
        p = c;
        c = headkopie;
      }
    
      //deleteBack
      if(head.next == null){
        head = null;
      }
      else{
        Node temp = head;
        while(temp.next.next != null){
          temp = temp.next;
        }
        temp.next = null;
      }

      //shift (safe, v1)
      if(head == null || head.next == null){
        return;
      }
      Node old_head = head;
      head = head.next;
      Node temp = head;
      while(temp.next != null){
        temp = temp.next;
      }
      old_head.next = null;
      temp.next = old_head;
    }
  }
  
  public void rds2(){    
    while(head != null && head.next != null){ 
      //reverse
      Node p = head;
      Node c = head.next;
      Node headkopie = head;
      p.next = null;
      while(c != null){
        head = c;
        headkopie = c.next;
        c.next = p;
        p = c;
        c = headkopie;
      }
    
      //deleteBack
      if(head.next == null){
        head = null;
      }
      else{
        Node temp = head;
        while(temp.next.next != null){
          temp = temp.next;
        }
        temp.next = null;
      }

      //shift_full_circle
      Node original_start = this.head;
      Node last_shift = this.head.next;

      while(original_start != last_shift){
        Node old_head = head;
        head = head.next;
        Node temp = head;
        while(temp.next != null){
          temp = temp.next;
        }
        old_head.next = null;
        temp.next = old_head;

        last_shift = head;
      }

      //shift (safe, v1)
      if(head == null || head.next == null){
        return;
      }
      Node old_head = head;
      head = head.next;
      Node temp = head;
      while(temp.next != null){
        temp = temp.next;
      }
      old_head.next = null;
      temp.next = old_head;
    }
  }
  
  /*
  while liste ist da
    reverse
    delete back
    while full circle
      bubble
      shift
  */
  public void combine1(){
    while(head != null && head.next != null){
      //reverse
      Node p = head;
      Node c = head.next;
      Node headkopie = head;
      p.next = null;
      while(c != null){
        head = c;
        headkopie = c.next;
        c.next = p;
        p = c;
        c = headkopie;
      }
    
      //deleteBack
      if(head.next == null){
        head = null;
      }
      else{
        Node temp = head;
        while(temp.next.next != null){
          temp = temp.next;
        }
        temp.next = null;
      }

      //shift_full_circle
      Node original_start = this.head;
      Node last_shift = this.head.next;

      while(original_start != last_shift){
        Node old_head = head;
        head = head.next;
        Node temp = head;
        while(temp.next != null){
          temp = temp.next;
        }
        old_head.next = null;
        temp.next = old_head;

        last_shift = head;
      }

      //bubble
      Node nh = head.next;
      head.next = nh.next;
      nh.next = head;
      head = nh;
      Node pr = head;
      Node f = head.next;
      Node s = head.next.next;
      while(s.next != null){
        pr.next = s;
        f.next = s.next;
        s.next = f;
        pr = s;
        s = f.next;
      }    
    }
  }
  
  public void combine2(){
    while(true){
      //deleteElementFront
      //head = head.next;
      
      //bubble
      Node nh = head.next;
      head.next = nh.next;
      nh.next = head;
      head = nh;
      Node pr = head;
      Node f = head.next;
      Node s = head.next.next;
      while(s.next != null){
        pr.next = s;
        f.next = s.next;
        s.next = f;
        pr = s;
        s = f.next;
      }        
    }
  }
  
  public void combine3(){
    int i = 5;
    while(i > 0){
      i--;
      int j = 5;
      while(j > 0){
        j--;
        
        //shift_full_circle
        Node original_start = this.head;
        Node last_shift = this.head.next;

        while(original_start != last_shift){
          Node old_head = head;
          head = head.next;
          Node temp = head;
          while(temp.next != null){
            temp = temp.next;
          }
          old_head.next = null;
          temp.next = old_head;

          last_shift = head;
         }

      }
    }
  }

  public void combine4(){
    int i = 5;
    while(i > 0){
      i--;
      int j = 5;
      while(j > 0){
        j--;
        int k = 5;
        while(k > 0){
          k--;
        
        int l = 5;
        while(l > 0){
        l--;
          int m = 5;
            while(m > 0){
              m--;
              int n = 5;
              while(n > 0){
                n--;
                
        //shift_full_circle
        Node original_start = this.head;
        Node last_shift = this.head.next;

        while(original_start != last_shift){
          Node old_head = head;
          head = head.next;
          Node temp = head;
          while(temp.next != null){
            temp = temp.next;
          }
          old_head.next = null;
          temp.next = old_head;

          last_shift = head;
         }
         
         }
         }
         }
         }
      }
    }
  }
  
  
  public void combine5(){
    int i = 5;
    while(i > 0){
      i--;
      int j = 5;
      while(j > 0){
        j--;
        int k = 5;
        while(k > 0){
          k--;
        
        int l = 5;
        while(l > 0){
        l--;
                    //reverse
      Node p = head;
      Node c = head.next;
      Node headkopie = head;
      p.next = null;
      while(c != null){
        head = c;
        headkopie = c.next;
        c.next = p;
        p = c;
        c = headkopie;
      }
    

              
              int n = 5;
              while(n > 0){
                n--;
                
        //shift_full_circle
        Node original_start = this.head;
        Node last_shift = this.head.next;

        while(original_start != last_shift){
          Node old_head = head;
          head = head.next;
          Node temp = head;
          while(temp.next != null){
            temp = temp.next;
          }
          old_head.next = null;
          temp.next = old_head;

          last_shift = head;
         }
         
         }
         
         }
         }
      }
    }
  }

  public void reverseDeleteNested(){
    while(head != null && head.next != null){
      Node p = head;
      Node c = head.next;
      Node headkopie = head;
      p.next = null;
      while(c != null){
        head = c;
        headkopie = c.next;
        c.next = p;
        p = c;
        c = headkopie;
        
        Node c2 = c;
        while(c2 != null && c2.next != null && c2.next.next != null){
          c2 = c2.next;
        }
        c2.next = c2.next.next;
      }
    }
  }
  
  public void reverseDeleteAddNested(){
    while(head != null && head.next != null){
      Node p = head;
      Node c = head.next;
      Node headkopie = head;
      p.next = null;
      while(c != null){
        head = c;
        headkopie = c.next;
        c.next = p;
        p = c;
        c = headkopie;
        
        Node c2 = c;
        while(c2 != null && c2.next != null && c2.next.next != null){
          c2 = c2.next;
          
          Node c3 = c2;
          while(c3 != null && c3.next != null){
            c3 = c3.next;
          }
          if(c3 != null){
            c3.next = new Node();
          }
        }
        c2.next = c2.next.next;
      }
    }
  }
  
  public void reverseDeleteAddDeleteNested(){
    while(head != null && head.next != null){
      Node p = head;
      Node c = head.next;
      Node headkopie = head;
      p.next = null;
      while(c != null){
        head = c;
        headkopie = c.next;
        c.next = p;
        p = c;
        c = headkopie;
        
        Node c2 = c;
        while(c2 != null && c2.next != null && c2.next.next != null){
          c2 = c2.next;
          
          Node c3 = c2;
          while(c3 != null && c3.next != null){
            c3 = c3.next;
            
            Node c4 = c3;
            while(c4 != null && c4.next != null && c4.next.next != null){
              c4 = c4.next;
            }
            c4.next = null;
          }
          if(c3 != null){
            c3.next = new Node();
          }
        }
        c2.next = c2.next.next;
      }
    }
  }
  
  private class Node{
    Node next;
    int value;

    public Node(){
      next = null;
    }

    public Node(int value){
      next = null;
      this.value = value;
    }
  }
}
