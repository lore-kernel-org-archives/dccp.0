From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 12 Dec 2007 17:21:44 +0000
Subject: Re: [PATCH 8/8] [PATCH v2] [CCID3]: Interface CCID3 code with newer Loss Intervals Database
Message-Id: <20071212172144.GA3560@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

| > +static struct kmem_cache  *tfrc_lh_slab  __read_mostly;	/* <=3D=3D */
|=20
| Yup, this one, is introduced as above but is not initialized at the
| module init routine, please see, it should be OK and we can move on:
|=20
| http://git.kernel.org/?p=3Dlinux/kernel/git/acme/net-2.6.25.git;a=3Dcommi=
tdiff;h=A925429ce2189b548dc19037d3ebd4ff35ae4af7
|=20
Sorry for the confusion - you were right, the initialisation was sitting
in the wrong patch, not the one in the subject line. In your online
version the problem is fixed. Thanks a lot for all the work and for the
clarification.

Gerrit
