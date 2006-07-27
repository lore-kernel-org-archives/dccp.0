From: "Ma Lin" <gavin.malin@gmail.com>
Date: Thu, 27 Jul 2006 01:17:53 +0000
Subject: RE: Help: how to get the latest code?
Message-Id: <c583c3410607261817v410c5d8qbd1c4965db180548@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <c583c3410607250521t1501d5f6i76e3c62e532c225a@mail.gmail.com>
In-Reply-To: <c583c3410607250521t1501d5f6i76e3c62e532c225a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thank you Ian, the patch works.
For those who have the same question as I have, here is what I did.
1. download linux-kernel.2.6.17.6.tar.gz , for example, here:
http://mirror.comp.nus.edu.sg/kernel/linux/linux/kernel/v2.6/linux-2.6.17.6.tar.gz
2. unzip and untar linux-kernel.2.6.17.6.tar.gz to /usr/src/kernels/
3. download patches from http://darkircop.org/dccp/ as save them in
/usr/src/kernels/patch/
patchs in subdir 1 should be applied first then, 2. Patches with
small-number-prefix is to be applied before others:
================cd /usr/src/kernels/linux-2.6.17.6

patch -p1 <../patch/andrea/1/01_ackvec_len
patch -p1 <../patch/andrea/1/02_ackvec_state
patch -p1 <../patch/andrea/1/03_ackvec_remove_unused
patch -p1 <../patch/andrea/1/04_ccid2_jiffies_wrap
patch -p1 <../patch/andrea/1/05_ccid2_seq_alloc
patch -p1 <../patch/andrea/1/06_ccid2_ssthresh
patch -p1 <../patch/andrea/1/07_ccid2_send_poll
patch -p1 <../patch/andrea/1/08_ccid2_cwnd
patch -p1 <../patch/andrea/1/09_ccid2_debug
patch -p1 <../patch/andrea/1/10_ccid2_change
patch -p1 <../patch/andrea/1/11_ccid2_profile
patch -p1 <../patch/andrea/2/01_ackvec_opt
patch -p1 <../patch/andrea/2/02_ackvec_speed
patch -p1 <../patch/andrea/2/03_ackvec_ccid_speed

malin
On 7/26/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 7/26/06, Ma Lin <gavin.malin@gmail.com> wrote:
> > Andrea,
> > How can I apply your patches at http://darkircop.org/dccp/ to my local
> > DCCP code?
> > I have a copy of kernel 2.6.17-1 on PC, the code is not downloaded by
> > git, so there is no git repository.
> > Sorry, if the question is too stupid, relly too novice :)
> > Also, thanks to Ian for the previous answer.
> >
> > malin
>
> For most patches save to a text file, change into the top level of
> your source code tree and then type:
> patch -p1 < patchname
>
> --
> Ian McDonald
> Web: http://wand.net.nz/~iam4
> Blog: http://imcdnzl.blogspot.com
> WAND Network Research Group
> Department of Computer Science
> University of Waikato
> New Zealand
>
