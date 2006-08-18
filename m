From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 18 Aug 2006 17:59:57 +0000
Subject: Re: [BUG] CCID3 - loss not detected if in order
Message-Id: <5640c7e00608181059n3973e608o9684ed8de8b1ee6a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00607201930k6650084oc75a868a6011a525@mail.gmail.com>
In-Reply-To: <5640c7e00607201930k6650084oc75a868a6011a525@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/19/06, burakgmail-dccp@yahoo.com <burakgmail-dccp@yahoo.com> wrote:
> Hi again,
>
> Made more tests. Recompiled the kernel with lossfix and ccid3li patches only, but no difference. The receiver freezes. Below is the /var/log/messages related with the problem  on the receiver box.
>
Hi there Burak,

Yes it is a work in progress. I've actually fixed the receiver up and
now need to get the transmitter going at the correct rate. I'll try
and post my interim fixes to web later today and get some proper ones
early next week.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
