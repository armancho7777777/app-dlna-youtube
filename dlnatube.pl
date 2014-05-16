#!perl -w
use strict;
use Carp qw(croak);
use Data::Dumper;

use AnyEvent;
use AnyEvent::DLNAServer::MediaServer;
use JWZ::YouTubeDown;
#use Video::FindStream;
use File::Spec;
use Getopt::Long;

GetOptions(
    'referrer|r:s' => \my $referrer,
);

my $media= AnyEvent::DLNAServer::MediaServer->new();
my $info;
#my $info= $media->add_file('//aliens/media/movies/Tim.Burtons.Vincent.avi');
#$info= $media->add_file(File::Spec->rel2abs('Calvin Harris - Feel So Close (2011).mp4'));

if( @ARGV ) {
    my $resource= $ARGV[0];
    
    if( -f $resource) {
        $info= $media->add_file($resource, expires => 180);
    } elsif ( $resource =~ /vimeo|youtu/ ) {
        # jwz got this
        my $yt_info= JWZ::YouTubeDown::fetch_url_info($resource);
        $info= $media->add_url($yt_info->{url}, expires => 180);
    } else {
        # must be a real stream url
        #my $vid_info= Video::FindStream::fetch_url_info($resource) || { url => $resource };
        my $vid_info= { url => $resource };
        $info= $media->add_url($vid_info->{ url }, expires => 180, referrer => $referrer);
    };
} else {
    $info= $media->add_file(File::Spec->rel2abs('Calvin Harris - Feel So Close (2011).mp4'));
};

my $url= $info->{dlna_url};
warn "Playing $url";
system("start perl -w dlna-play-url.pl $url");
#system(qq{start "Test" "$url"});

warn "Waiting for things to happen";
#my $done= AnyEvent->condvar;
#my $timeout= AnyEvent->timer( after => 120, cb => $done );
#$done->recv;
AnyEvent->condvar->recv;