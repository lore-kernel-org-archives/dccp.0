From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 21 Jun 2006 10:52:56 +0000
Subject: Re: Locking validator output on DCCP
Message-Id: <20060621105256.GA21015@elte.hu>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
In-Reply-To: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > Can someone tell me whether I am correct in my thinking or not? If I 
> > am then I will work out how to tell the lock validator not to worry 
> > about it.
> 
> I agree, this looks bogus.  Ingo, could you please take a look?

sure - Ian, could you try Arjan's fix below?

	Ingo

------------------------------------------------------------
Subject: lock validator: annotate vlan "master" device locks
From: Arjan van de Ven <arjan@linux.intel.com>

vlan devices are "masters" of normal "slave" devices and thus need their 
own lock key. (this will be switched to the reinit_key APIs once they 
are available)

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>

---
 net/8021q/vlan.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6.17-rc6-mm2/net/8021q/vlan.c
=================================--- linux-2.6.17-rc6-mm2.orig/net/8021q/vlan.c
+++ linux-2.6.17-rc6-mm2/net/8021q/vlan.c
@@ -463,6 +463,8 @@ static struct net_device *register_vlan_
 	if (new_dev = NULL)
 		goto out_unlock;
 
+	spin_lock_init(&dev->xmit_lock);
+
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "Allocated new name -:%s:-\n", new_dev->name);
 #endif

