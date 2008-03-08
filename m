From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 08 Mar 2008 00:47:45 +0000
Subject: Re: packet priorities
Message-Id: <5640c7e00803071647q5d5de8cap9c0c4d01378adc73@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2008/3/8 Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>:
>  The next step would be to use it in VLC stream_out module to make for example
>  sound more important (and thus more likely to arrive to destination
>  endpoint). I played a bit with VLC code and it seems it would be possible
>  (some MPEG Transport Stream packet reordering will be necessary).
>  Prioritizing sound over video should be especially useful in video
>  conferencing but for now I'm not going to implement it. That's simply because
>  I'm afraid that testing conditions could be highly variable and difficult to
>  reproduce. Let's stick to something predictable for now.
>
That is exactly what my research is about. Read some of my papers...

>  The deadline is not that easy to determine due to client side buffering. At
>  least that would require cooperation on receiving side. For now I just assume
>  that some packets are simply more important than others. That is they convey
>  more information to the one who is watching. When streaming football match
>  you are probably less interested in voice comments, music and applause and
>  more about "where is the ball?" (video more important). But when watching the
>  news usually audio is much more important than the object on video that
>  you've already seen thousands of times.

You can track the rtt and also mark the expiry time and do the maths.
Again check my papers...

-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
