From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 28 Nov 2006 19:34:26 +0000
Subject: Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <5640c7e00611281134g3c869bb7r3145e21918c2ddf5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611281435.05466@strip-the-willow>
In-Reply-To: <200611281435.05466@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/29/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Use `unsigned' for packet lengths
>
I'm wondering whether this code is 64 bit safe??? I don't think it is.
Arnaldo can probably advise.

We changed int to u32 for length and I went and checked the callers
and parameters. They all basically go back to skb->len which is an
unsigned int. So at least we did the right thing changing to unsigned
as we were mismatched before.

As much as I would like to change sk_buff definition to __u32 and save
2 bytes on 64 bit I don't think we can really as that is in a
userspace include as I understand it and therefore we would break
programs...

Regards,

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
