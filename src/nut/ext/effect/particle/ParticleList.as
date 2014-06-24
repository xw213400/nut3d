package nut.ext.effect.particle
{
	public class ParticleList
	{
		public var head:Particle	= null;
		public var num	:uint		= 0;
		
		public function ParticleList()
		{
		}

		public function reSize(n:uint) :void
		{
			num = 0;
			head = null;
			
			while (num!=n)
			{	
				var p:Particle = new Particle(num);
				p.next = head;
				head = p;
				
				++num;
			}
		}
		
		public function remove(last:Particle, curr:Particle) :Particle
		{
			num--;
			if (last == null)
			{
				head = curr.next;
				return head;
			}
			else
			{
				last.next = curr.next;
				return last.next;
			}
		}
		
		public function add(p:Particle) :void
		{
			p.next = head;
			head = p;
			
			num++;
		}
	}
}