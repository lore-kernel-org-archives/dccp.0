From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 20 Oct 2008 13:13:55 +0000
Subject: Re: Protocol not attached
Message-Id: <20081020131355.GK19353@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Oct 18, 2008 at 01:06:28PM +0200, Gerrit Renker escreveu:

<SNIP>

> Incidentally the new netdev-2.6 has a commit called "Remove CONFIG_KMOD from
> net/ (towards removing KMOD entirely)", so perhaps there is something in
> progress.

Is CONFIG_MODULES present in the config file that produces a kernel that
has the problem?

I guess not, Leandro, can you please add it manually, then do a make
oldconfig, check that it is still there, then build the kernel?

This is the part of the patch Gerrit mentioned
(95a5afca4a8d2e1cb77e1d4bc6ff9f718dc32f7a) that could be hitting you.


diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
index 4809753..8fe931a 100644
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -154,7 +154,7 @@ struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx, gfp_t gfp)
        struct ccid *ccid = NULL;
 
        ccids_read_lock();
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
        if (ccids[id] = NULL) {
                /* We only try to load if in process context */
                ccids_read_unlock();

- Arnaldo
