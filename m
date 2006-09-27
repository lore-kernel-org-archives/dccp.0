From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 27 Sep 2006 21:33:11 +0000
Subject: Re: Sequence numbers in Response packets (Linux 2.6.17)
Message-Id: <5640c7e00609271433u79b610dfmf7c5267a7568b4cb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <E1GSY22-000OxT-00.vladivm-mail-ru@f75.mail.ru>
In-Reply-To: <E1GSY22-000OxT-00.vladivm-mail-ru@f75.mail.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/27/06, Vladimir M <vladivm@mail.ru> wrote:
>
> Hi,
>
> While doing some tresting, I've noticed a funny behaviour of DCCP implementation in 2.6 kernel. From Ethereal capture seems that retransmitted response packets do not increment the sequence number. Is it a correct behaviour? If yes, then why is it done like this, since protocol's RFC instructs to increment on every outgoing packet.
>
> B.R.
> Vladimir.
>
> P.S. Don't know, it it has been already discussed on the list or not, or even patched. I have original DCCP version from 2.6.17 FC5, but havnt found anything related in archives of this list

Vladimir,

You are correct in saying this and it hasn't been fixed yet as of the
latest code. The reason for this is that we just clone the skb and
haven't updated the header. Feel free to get in and fix if you want!

I have added this to the DCCP to do list -
http://linux-net.osdl.org/index.php/TODO#DCCP

Thanks,

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
