From: Arjan van de Ven <arjan@linux.intel.com>
Date: Wed, 21 Jun 2006 10:18:11 +0000
Subject: Re: Locking validator output on DCCP
Message-Id: <1150885091.3057.30.camel@laptopd505.fenrus.org>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
In-Reply-To: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, 2006-06-21 at 10:34 +1000, Herbert Xu wrote:
> > As I read this it is not a recursive lock as sk_clone is occurring
> > second and is actually creating a new socket so they are trying to
> > lock on different sockets.
> > 
> > Can someone tell me whether I am correct in my thinking or not? If I
> > am then I will work out how to tell the lock validator not to worry
> > about it.
> 
> I agree, this looks bogus.  Ingo, could you please take a look?

Fix is relatively easy:


sk_clone creates a new socket, and thus can never deadlock, and in fact
can be called with the original socket locked. This therefore is a
legitimate nesting case; mark it as such.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>


---
 net/core/sock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.17-rc6-mm2/net/core/sock.c
=================================--- linux-2.6.17-rc6-mm2.orig/net/core/sock.c
+++ linux-2.6.17-rc6-mm2/net/core/sock.c
@@ -846,7 +846,7 @@ struct sock *sk_clone(const struct sock 
 		/* SANITY */
 		sk_node_init(&newsk->sk_node);
 		sock_lock_init(newsk);
-		bh_lock_sock(newsk);
+		bh_lock_sock_nested(newsk);
 
 		atomic_set(&newsk->sk_rmem_alloc, 0);
 		atomic_set(&newsk->sk_wmem_alloc, 0);

