module QuestBack
  # Public: Simple debug observer.
  #
  # Hijacks operations and pretty prints XML which could have been sent.
  class DebugObserver
    def notify(operation_name, builder, globals, locals)
      logger = globals[:logger]

      logger.info "!!!!!!!!!"
      logger.info "!!! SOAP request hijacked by #{self.class.name}."
      logger.info "!!!!!!!!!"

      logger.debug "\n\n" + Nokogiri.XML(builder.to_s).to_xml + "\n"

      HTTPI::Response.new(200, {}, '')
    end
  end
end
