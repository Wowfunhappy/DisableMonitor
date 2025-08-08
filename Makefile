# DisableMonitor CLI Makefile
# Build without Xcode for OS X 10.9 Mavericks

CC = clang
OBJC = clang
CFLAGS = -Wall -O2 -mmacosx-version-min=10.9
OBJCFLAGS = $(CFLAGS) -fobjc-arc -Wno-deprecated-declarations

# Frameworks
FRAMEWORKS = -framework Foundation \
             -framework ApplicationServices \
             -framework IOKit \
             -framework CoreGraphics

# Source files
SOURCES = main_cli.m \
          MonitorControl.m \
          MonitorDataSource_CLI.m \
          DisplayIDAndName.m \
          DisplayData.m \
          GLFW.m

# Object files
OBJECTS = $(SOURCES:.m=.o)

# Target
TARGET = disablemonitor

# Default target
all: $(TARGET)

# Build the executable
$(TARGET): $(OBJECTS)
	$(OBJC) $(OBJCFLAGS) $(FRAMEWORKS) -o $@ $^
	@echo "Build complete: $(TARGET)"

# Compile Objective-C files
%.o: %.m
	$(OBJC) $(OBJCFLAGS) -c $< -o $@

# Clean build artifacts
clean:
	rm -f $(OBJECTS) $(TARGET)
	@echo "Clean complete"

# Install to /usr/local/bin
install: $(TARGET)
	@echo "Installing to /usr/local/bin..."
	@mkdir -p /usr/local/bin
	@cp $(TARGET) /usr/local/bin/
	@chmod 755 /usr/local/bin/$(TARGET)
	@echo "Installation complete"

# Uninstall from /usr/local/bin
uninstall:
	@echo "Removing from /usr/local/bin..."
	@rm -f /usr/local/bin/$(TARGET)
	@echo "Uninstall complete"

# Show help
help:
	@echo "DisableMonitor CLI Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make         - Build the disablemonitor CLI tool"
	@echo "  make clean   - Remove build artifacts"
	@echo "  make install - Install to /usr/local/bin"
	@echo "  make uninstall - Remove from /usr/local/bin"
	@echo "  make help    - Show this help message"

.PHONY: all clean install uninstall help