package org.osflash.mixins
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class MixinBindingList
	{

		public static const NIL : MixinBindingList = new MixinBindingList(null, null);

		// Although those variables are not const, they would be if AS3 would handle it correctly.
		public var head : IMixinBinding;
		
		public var tail : MixinBindingList;
		
		public var nonEmpty : Boolean = false;
		
		/**
		 * Creates and returns a new MixinBindingList object.
		 *
		 * <p>A user never has to create a MixinBindingList manually. Use the <code>NIL</code> 
		 * element to represent an empty list. <code>NIL.prepend(value)</code> would create a list 
		 * containing <code>value</code>.</p>
		 *
		 * @param head The head of the list.
		 * @param tail The tail of the list.
		 */
		public function MixinBindingList(head : IMixinBinding, tail : MixinBindingList = null)
		{
			if (!head && !tail)
			{
				if (NIL) throw new ArgumentError(
						'Parameters head and tail are null. Use the NIL element instead.');

				//this is the NIL element as per definition
				nonEmpty = false;
			}
			else
			{
				this.head = head;
				this.tail = tail || NIL;
				nonEmpty = true;
			}
		}

		/**
		 * The length of the list.
		 */
		public function get length() : uint
		{
			if (!nonEmpty) return 0;
			if (tail == NIL) return 1;

			// We could cache the length, but it would make methods like filterNot 
			// unnecessarily complicated. Instead we assume that O(n) is okay since the length 
			// property is used in rare cases. We could also cache the length lazy, but that is 
			// a waste of another 8b per list node (at least).

			var result : uint = 0;
			var p : MixinBindingList = this;

			while (p.nonEmpty)
			{
				++result;
				p = p.tail;
			}

			return result;
		}
		
		public function prepend(binding:IMixinBinding) : MixinBindingList
		{
			return new MixinBindingList(binding, this);
		}

		/**
		 * Clones the list and adds a binding to the end.
		 * @param	binding
		 * @return	A new list with the binding appended to the end.
		 */
		public function append(binding : IMixinBinding) : MixinBindingList
		{
			if (!binding) return this;
			if (!nonEmpty) return new MixinBindingList(binding);
			// Special case: just one binding.
			if (tail == NIL) 
				return new MixinBindingList(binding).prepend(head);
			
			const wholeClone : MixinBindingList = new MixinBindingList(head);
			var subClone : MixinBindingList = wholeClone;
			var current : MixinBindingList = tail;

			while (current.nonEmpty)
			{
				subClone = subClone.tail = new MixinBindingList(current.head);
				current = current.tail;
			}
			// Append the new binding last.
			subClone.tail = new MixinBindingList(binding);
			return wholeClone;
		}		
		
		public function filterNot(key : Class) : MixinBindingList
		{
			if (!nonEmpty || key == null) return this;

			if (key == head.key) return tail;

			// The first item wasn't a match so the filtered list will contain it.
			const wholeClone : MixinBindingList = new MixinBindingList(head);
			var subClone : MixinBindingList = wholeClone;
			var current : MixinBindingList = tail;
			
			while (current.nonEmpty)
			{
				if (current.head.key == key)
				{
					// Splice out the current head.
					subClone.tail = current.tail;
					return wholeClone;
				}
				
				subClone = subClone.tail = new MixinBindingList(current.head);
				current = current.tail;
			}

			// The listener was not found so this list is unchanged.
			return this;
		}

		public function contains(key : Class) : Boolean
		{
			if (!nonEmpty) return false;

			var p : MixinBindingList = this;
			while (p.nonEmpty)
			{
				if (p.head.key == key) return true;
				p = p.tail;
			}

			return false;
		}

		public function find(key : Class) : IMixinBinding
		{
			if (!nonEmpty) return null;

			var p : MixinBindingList = this;
			while (p.nonEmpty)
			{
				if (p.head.key == key) return p.head;
				p = p.tail;
			}

			return null;
		}

		public function toString() : String
		{
			var buffer:String = '';
			var p : MixinBindingList = this;

			while (p.nonEmpty)
			{
				buffer += p.head + " -> ";
				p = p.tail;
			}

			buffer += "NIL";

			return "[List "+buffer+"]";
		}
	}
}
