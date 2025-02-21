package beispiel1;

public class Liste{
	Node head;

	public Liste(){
		head = null; //wahrscheinlich ist das nicht noetig, aber zum testen der Analyse evtl. nuetzlich.
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

	public void addElementFront(int value){
		if(head == null){
			head = new Node(value);
		}
		else{
			Node newHead = new Node(value);
			newHead.next = head;
			head = newHead;
		}
	}

	//im zweifelsfall ans Ende anhaengen.
	public void addElementAtIndex(int value, int index){
		if(index<0) return;
		else if(head==null){
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
				if(temp.next != null)
					temp = temp.next;
				else
					break;
			}
			Node temp2=temp.next;
			temp.next = new Node(value);
			temp.next.next = temp2;
		}
	}

	//im Zweifelsfall nix loeschen
	public void deleteElementAtIndex(int index){
		if(index<0) return;
		else if(index==0){
			head = head.next;
		}
		else{
			Node beforeDeleteGoal = head;
			while((index-1)>0){
				index--;
				if(beforeDeleteGoal.next != null)
					beforeDeleteGoal = beforeDeleteGoal.next;
				else
					return;
			}
			if(beforeDeleteGoal.next != null) //hier keine Unterscheidung auf null oder nicht null mehr noetig, weil bDG.n.n == null erlaubt ist.
				beforeDeleteGoal.next = beforeDeleteGoal.next.next;
		}
	}

	public Node getFirstNode(){
		return head;
	}

	//Eigentlich wuerde es mehr Sinn machen, eine ganze andere Liste zu uebergeben, aber ich weiss grad nicht, wie man das gescheit einbaut mit Java, und fuer die Analyse sollte es wayne sein.
	public void append(Node andereListe){
		if(head==null)
			head = andereListe;
		else{
			Node temp = head;
			while(temp.next!=null)
				temp = temp.next;
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
	  if(head==null){
	    return;
	  }
	  else if(head.next==null){
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
