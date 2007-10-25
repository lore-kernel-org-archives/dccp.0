From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Thu, 25 Oct 2007 03:47:42 +0000
Subject: Gstreamer e DCCP: issues related to ccid-3
Message-Id: <5bc4c4570710242047h1d9b1c64k6381ba5c3a421355@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Can you please revise to me the problem that you and the VLC guy had
while was implement DCCP support on VLC?
   I'm implementing the dccp plugin for gstreamer and everything goes
very well, I can transmit an mp3 sound using ccid-2, but when I try to
use ccid-3, I can just send very little via send function and after
the function returns 11 (EAGAIN). Is there any different parameter
that I should set? I think that the problem that you had in VLC should
be the same for me and in this case you help me. I have been working
with Arnaldo on this stuffs but I decided to make it public sharing
this problem to all of you and get some help.
   Basically the functions that I'm using to send are the following:

PS: the second function, gst_dccp_send_buffer, is a call back function
called by gstreamer when it has data to be sent. Thank you.

/* write buffer to given socket incrementally.
 * Returns number of bytes written.
 */
gint
gst_dccp_socket_write (int socket, const void *buf, size_t count)
{
 size_t bytes_written = 0;
 ssize_t wrote;

 while (bytes_written < count) {
   wrote = send (socket, (const char *) buf + bytes_written,
           count - bytes_written, MSG_NOSIGNAL);
   if (wrote <= 0) {
     return bytes_written;
   }
   bytes_written += wrote;
 }

 if (bytes_written < 0)
   GST_WARNING ("error while writing");
 else
   GST_LOG ("wrote %" G_GSIZE_FORMAT " bytes succesfully", bytes_written);
 return bytes_written;
}


/* write a GDP header to the socket.  Return false if fails. */
GstFlowReturn
gst_dccp_send_buffer (GstElement * this, GstBuffer * buffer, int socket)
{
 size_t wrote;

 gint size = 0;
 guint8 *data;

 size = GST_BUFFER_SIZE (buffer);
 data = GST_BUFFER_DATA (buffer);

 GST_LOG_OBJECT (this, "writing %d bytes for GDP buffer header\n", size);
 printf("writing %d bytes for GDP buffer header\n\n", size);
 wrote = gst_dccp_socket_write (socket, data, size);
 //g_free (data);

 if (wrote != size) {
   GST_ELEMENT_ERROR (this, CORE, TOO_LAZY, (NULL),
       ("Error while sending data"));
   printf("Error while sending data\n");
   return GST_FLOW_ERROR;
 }

 return GST_FLOW_OK;
}
