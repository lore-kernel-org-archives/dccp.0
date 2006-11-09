From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 09 Nov 2006 19:45:29 +0000
Subject: Re: Sequence numbers in Response packets (Linux 2.6.17)
Message-Id: <5640c7e00611091145n6dbbc9c8j16bb62eb2fc08d2a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <E1GSY22-000OxT-00.vladivm-mail-ru@f75.mail.ru>
In-Reply-To: <E1GSY22-000OxT-00.vladivm-mail-ru@f75.mail.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Although this is a relatively minor bug, I believe it would be better to stick by the DCCP rule
> that `each outgoing packet has its sequence number incremented' and will send a patch.
>
> Ian, I will remove this ToDo from the list, ok?
>
> Thanks to Vladimir for pointing this out; but it would in future be much more helpful to
> have some real traces to work on - otherwise it really is hard to figure out the causes.
>
> Gerrit
>
>
Thanks Gerrit for doing the legwork on this one. As you say the bug is
more minor than first identified. I'm happy for you to update the ToDo
list with this info or remove once you've sent your patch.

You're doing well to work through these. Just wish I had more time to help!

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
