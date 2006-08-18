From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 18 Aug 2006 19:47:48 +0000
Subject: Re: [BUG] CCID3 - loss not detected if in order
Message-Id: <5640c7e00608181247l7b22415tcb4e4cd79028ec2b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00607201930k6650084oc75a868a6011a525@mail.gmail.com>
In-Reply-To: <5640c7e00607201930k6650084oc75a868a6011a525@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Yes it is a work in progress. I've actually fixed the receiver up and
> now need to get the transmitter going at the correct rate. I'll try
> and post my interim fixes to web later today and get some proper ones
> early next week.
>
OK newer patches are at http://wand.net.nz/~iam4/dccp/patches/

Apply all apart from bestpacketnext - the order is listed at series.
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
