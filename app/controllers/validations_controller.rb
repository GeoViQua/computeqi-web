class ValidationsController < Remote::RemotableController

  alias :super_create :create

  def create
    if @project.class == ValidationProject
      observed_hash = params[:validation][:observed]
      predicted_hash = params[:validation][:predicted]

      observed = Array.new
      predicted = Array.new

      missing_value = params[:validation][:missing_value_code].to_f

      observed_hash.each do |id, value|
        parsed_obs = parse_value(value)
        parsed_pred = parse_value(predicted_hash[id])
        if parsed_obs != missing_value and parsed_pred != missing_value
          observed << parsed_obs
          predicted << parsed_pred
        end
      end

      params[:validation][:observed] = observed
      params[:validation][:predicted] = predicted
    end
    super_create
  end

  def edit
    # to get try again link working
    refresh
  end

  def show_respond_to(format)
    format.json {
      if params[:data]
        hash = @validation.send("#{params[:data]}_data")
        render json: hash.to_hash
      else
        render json: @validation.to_hash
      end
    }
  end

  def refresh
    @validation = Validation.find(params[:id])
    Delayed::Job.enqueue RemoteJob.new(@validation)
    redirect_to validation_path(@validation)
  end

  def show_metadata
    @validation = Validation.find(params[:id])
  end

  def new_metadata
    @validation = Validation.find(params[:id])
    begin
      unless params[:file].nil?

        # insert the metadata into the uploaded XML file
        xml = insert_metadata_into_xml(params[:file].tempfile)

        # Render the modified XML
        return render xml: xml
      end
    rescue Exception => e
      logger.fatal e
      flash[:error] = "There was an error processing your document. Please ensure that the XML is not malformed."
    end
    # redirect back to the report view with any error messages
    redirect_to validation_path(@validation)
  end

  private

  def insert_metadata_into_xml(document)
    # create a document from a String or File
    doc = Nokogiri::XML(document) do |config|
      # throw error when parsing malformed documents & prevent network connections during parsing
      config.strict.nonet
    end

    # parse the partial used to generate the XML
    fragment = doc.fragment render_to_string(partial: "metadata/combined", formats: :xml, locals: { object: @validation })

    # collect all the namespaces in the document
    namespaces = doc.collect_namespaces

    # strip the leading xmlns: from each namespace key, and store in a new hash
    ns = Hash.new
    namespaces.each_pair do |key, value|
      ns[key.sub(/^xmlns:/, '')] = value
    end

    # insert the fragment after a valid node: either the last gvq:dataQualityInfo element or the last gmd namespaced child element of any root
    doc.xpath("/gvq:GVQ_Metadata/gvq:dataQualityInfo[last()] | /*/gmd:*[last()]", ns).after(fragment)

    return doc.to_xml
  end

  def parse_value(value)
    begin
      JSON.parse(value)
    rescue JSON::ParserError
      value.to_f
    end
  end
end
