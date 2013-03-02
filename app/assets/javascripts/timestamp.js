$.fn.relatizeTimestamps = function() {
  $(this).find(".timestamp").each(function() {
    var $this, time;
    $this = $(this);
    time = moment($this.text());
    return $this.text(time.fromNow()).attr("title", time.format("LLLL"));
  });
  return this;
};