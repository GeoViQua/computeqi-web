module ApplicationHelper
  def status_box(type, title, message, loading = nil)
    content_tag(:div, class: "alert alert-#{type.to_s} status") do
      content_tag(:strong, "#{title}!") + " " +
      message +
      if loading
        " This page will automatically refresh.".html_safe +
        image_tag("loading-#{type.to_s}.gif", class: "pull-right")
      end
    end
  end
  
  def page_header(title, sub)
    content_tag(:div, class: "page-header") do
      content_tag(:h1) do
        title.html_safe + " " + content_tag(:small, sub)
      end
    end
  end

  def project_status_icon(project)
    data = if project.complete?
      { icon: "ok-sign", title: "Complete" }
    elsif project.error?
      { icon: "exclamation-sign", title: "Error" }
    elsif project.busy?
      { icon: "refresh", title: "Busy" }
    end
    content_tag(:i, class: "icon-#{data[:icon]}", rel: "tooltip", title: data[:title]) {} if data
  end

  def remotable_status_icon(remotable)
    if !remotable.nil?
      data = if remotable.success?
        { icon: "ok-sign", title: "Complete" }
      elsif remotable.error?
        { icon: "exclamation-sign", title: "Error" }
      elsif remotable.in_progress?
        { icon: "refresh", title: "In progress" }
      elsif remotable.queued?
        { icon: "refresh", title: "Queued" }
      end
      content_tag(:i, class: "icon-#{data[:icon]}", rel: "tooltip", title: data[:title]) {}
    end
  end
  
  def remote_display(remotable, parent)
    content_tag(:div, id: "display") do
      remote_html(remotable, parent)
    end +
    content_tag(:script) do
      remote_script(remotable, parent)
    end.html_safe
  end
  
  def remote_ujs(remotable, parent)
    "var html = '#{escape_javascript(remote_html(remotable, parent))}';".html_safe +
    "var element = $('<div>' + html + '</div>');".html_safe +
    "if (element.html() !== $('#display').html()) { $('#display').fadeOut('fast', function() { $(this).html(html).slideDown(); }); }".html_safe +
    remote_script(remotable, parent)
  end
  
  def remote_html(remotable, parent)
    if remotable.finished?
      if remotable.success?
        render("display")
      else
        message = remotable.proc_message != nil ? remotable.proc_message : "I have nothing more to tell you."
        message << "." unless message =~ /[\.!?]\z/
        path_str = "edit_#{parent ? parent.class.to_s.underscore + "_" : ""}#{remotable.class.to_s.underscore}_path"
        status_box(:error, "Error", "#{remotable.proc_message} #{link_to('Try again?', send(path_str, parent, remotable))}".html_safe)
      end
    else
      object_name = remotable.class.to_s.underscore.humanize.downcase
      if remotable.in_progress?
        status_box(:info, "In progress", "Your #{object_name} is currently being generated.", true)
      else
        status_box(:info, "Queued", "Your #{object_name} is currently in a queue waiting to be processed.", true)
      end
    end
  end
  
  def remote_script(remotable, parent)
    if !remotable.finished?
      %Q{
setTimeout(function() {
  $.get('#{url_for([parent, remotable])}', function(response) {}, 'script');
}, 2500);
      }
    else "" end
  end
end
