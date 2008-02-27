From: "Leandro Sales" <leandroal@gmail.com>
Date: Wed, 27 Feb 2008 13:32:16 +0000
Subject: Re: [Announce] Release of the DCCP Plugin 0.2 for GStreamer
Message-Id: <5bc4c4570802270532m510d4716mba55aa1c9c782fba@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570802270510r563ad586qa74eaf6ef59b68e0@mail.gmail.com>
In-Reply-To: <5bc4c4570802270510r563ad586qa74eaf6ef59b68e0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Feb 27, 2008 at 10:20 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Oh good that it is out. While testing with the previous version
>  yesterday, I found out the following:
>
>   Streaming works with VLC as client, using the following configuration:
>
>   serverhost$ gst-launch -v filesrc location=music.mp3  ! dccpclientsink host2.168.1.99 port34
>
>   (VLC uses port 1234 by default).
>
>   On the receiver, one just needs to type dccp://@ to use the default port.
>   Here again the problem came up that the pipe feeds directly into the transmitter, so that soon all
>   data is streamed out. I tried this on localhost and this condition later caused all memory to be
>   exhausted. But between two separate hosts it worked.
>   The addition of mp3parse looks good.
>
>  Gerrit
>
>

Hello Gerrit,
   I was just writing an e-mail to you when I received one from you.
Yes, besides many fixes of the plugin (please refer to ChangeLog file
to the complete list) we provided a new example to solve you problem
in two ways, one using gst-launch and the other an c code example that
it is in the src/examples_app/mp3Stream directory. And yes, the
addition of mp3parse together with many improvements solved the
problem of using the plugin to stream to other applications. I think
that now we can also use the plugin to stream from here, to there,
where you are. I need just more time to setup the environment here.
After this will contact you. By the way, have you read that I added
the support of IPv6 in the TODO list? I talked to the gstreamer guys
and I already have all the requirements from them to submit the plugin
to them. The only one thing missing is the unittest that they required
and I'm now working on this issue and finally submit the plugin.
   That's a good news the plugin also worked with VLC. Thank you for the news.

Leandro.
